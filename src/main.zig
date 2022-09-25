pub const io_mode = .evented;

const std = @import("std");
const math = std.math;
const debug = std.debug;
const vec = @import("vec.zig");
const rtw = @import("rtweekend.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittableList.zig");
const sphere = @import("sphere.zig");
const camera = @import("camera.zig");
const material = @import("material.zig");
const randomScene = @import("randomScene.zig");

const PriorityQueue = std.PriorityQueue;
const Mutex = std.Thread.Mutex;
const Order = std.math.Order;

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const RandGen = rtw.RandGen;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const HittableList = hittableList.HittableList;
const Sphere = sphere.Sphere;
const Camera = camera.Camera;
const Material = material.Material;
const Scatter = material.Scatter;

const dot = vec.dot;
const f3 = rtw.f3;

const infinity = rtw.getInfinity(SType);

pub const Config = struct {
    // image config
    aspect_ratio: f32 = 3.0 / 2.0,
    image_width: usize = 1200,
    samples_per_pixel: usize = 500,
    max_depth: usize = 50,

    // camera config
    lookfrom: Point3 = Point3{ 13, 2, 3 },
    lookat: Point3 = Point3{ 0, 0, 0 },
    vup: Vec3 = Vec3{ 0, 1, 0 },
    vfov: f32 = 20.0,
    dist_to_focus: f32 = 10.0,
    aperture: f32 = 0.1,
};

fn rayColor(r: Ray, world: HittableList, rnd: *RandGen, depth: usize) Color {
    const black: Color = Color{ 0.0, 0.0, 0.0 };

    {
        var return_color = Color{ 1.0, 1.0, 1.0 };
        var scattered: Ray = r;
        var rec: HitRecord = undefined;

        var i: isize = 0;
        return while (i < depth) : (i += 1) {
            const world_hit = world.hit(scattered, 0.001, infinity);
            rec = world_hit.rec;
            if (world_hit.is_hit) {
                const s = rec.mat.scatter(scattered, rec, rnd);
                const is_scattered = s.is_scattered;
                scattered = s.scattered;
                const attenuation = s.attenuation;
                if (is_scattered) {
                    return_color *= attenuation;
                } else break black;
            } else {
                const unit_direction = vec.unit(scattered.direction);
                const t = 0.5 * (unit_direction[1] + 1.0);
                return_color *= (f3(1.0 - t) * Color{ 1.0, 1.0, 1.0 } + f3(t) * Color{ 0.5, 0.7, 1.0 });
                break return_color;
            }
        } else black;
    }
}

fn eqf(context: void, _: WorkerStruct, _: WorkerStruct) Order {
    _ = context;
    return Order.eq;
}

const PQeq = PriorityQueue(WorkerStruct, void, eqf);

const WorkerStruct = struct {
    i: usize,
    j: usize,
};

fn renderWorker(
    world: HittableList,
    max_depth: usize,
    rnd: *RandGen,
    image_width: usize,
    image_height: isize,
    samples_per_pixel: isize,
    num_task_remain: *u64,
    cam: Camera,
    mutex: *Mutex,
    queue: *PQeq,
    return_array_ptr: *[][]i64,
) !void {
    std.event.Loop.startCpuBoundOperation();

    var task: ?WorkerStruct = undefined;
    while (true) {
        if (mutex.*.tryLock()) {
            task = queue.*.removeOrNull();
            // const count = queue.*.count();
            mutex.*.unlock();

            if (task == null) {
                if (num_task_remain.* == 0) {
                    return;
                }
            } else {
                const i = task.?.i;
                const j = task.?.j;
                var pixel_color = Color{ 0, 0, 0 };
                {
                    var s: isize = 0;
                    while (s < samples_per_pixel) : (s += 1) {
                        const u: SType = (@intToFloat(SType, i) + rtw.getRandom(rnd, SType)) / @intToFloat(SType, image_width - 1);
                        const v: SType = (@intToFloat(SType, j) + rtw.getRandom(rnd, SType)) / @intToFloat(SType, image_height - 1);
                        const r = cam.getRay(u, v, rnd);
                        pixel_color += rayColor(r, world, rnd, max_depth);
                    }
                }
                const result = color.writeColor(pixel_color, samples_per_pixel);

                mutex.*.lock();
                return_array_ptr.*[i][j] = result;
                num_task_remain.* -= 1;
                const now_task_remain = num_task_remain.*;
                mutex.*.unlock();
                if (now_task_remain % 100 == 0) std.debug.print("remain tasks:\t{d}\n", .{num_task_remain.*});
            }
        }
    }
}

pub fn render(comptime config: Config, allocator: std.mem.Allocator) anyerror![][]i64 {
    var rnd = RandGen.init(0);

    var mutex: Mutex = .{};
    var queue = PQeq.init(allocator, {});
    var num_task_remain: u64 = 0;

    // image
    const aspect_ratio = config.aspect_ratio;
    const image_width: usize = config.image_width;
    comptime var image_height: usize = @intToFloat(@TypeOf(aspect_ratio), image_width) / aspect_ratio;
    const samples_per_pixel: usize = config.samples_per_pixel;
    const max_depth: usize = config.max_depth;

    // world
    var world = HittableList.init(allocator);
    defer world.deinit();
    try randomScene.genWorld(&rnd, &world);

    // camera
    const lookfrom = config.lookfrom;
    const lookat = config.lookat;
    const vup = config.vup;
    const vfov = config.vfov;
    const dist_to_focus = config.dist_to_focus;
    const apature = config.aperture;
    const cam = Camera.init(
        lookfrom,
        lookat,
        vup,
        vfov,
        aspect_ratio,
        apature,
        dist_to_focus,
    );

    // create return array
    var return_array: [][]i64 = undefined;
    return_array = try allocator.alloc([]i64, image_width);
    for (return_array) |*item| item.* = try allocator.alloc(i64, image_height);

    // Prepare thread
    const thread_count = try std.Thread.getCpuCount();
    std.debug.print("Thread count: {d}\n", .{thread_count});
    var promises =
        try allocator.alloc(@Frame(renderWorker), thread_count);
    defer allocator.free(promises);

    // Queue tasks
    std.debug.print("start queue tasks\n", .{});
    var j: usize = image_height;
    var i: usize = 0;
    while (0 < j) : (j -= 1) {
        i = 0;
        while (i < image_width) : (i += 1) {
            if (mutex.tryLock()) {
                try queue.add(WorkerStruct{ .i = i, .j = j - 1 });
                num_task_remain += 1;
                mutex.unlock();
            }
        }
    } else {
        std.debug.print("all tasks queued\n", .{});
    }

    // Start a worker on every cpu
    var c: usize = 0;
    while (c < thread_count) : (c += 1) {
        std.debug.print("{d}\n", .{c});
        promises[c] =
            async renderWorker(
            world,
            max_depth,
            &rnd,
            // writer,
            image_width,
            image_height,
            samples_per_pixel,
            &num_task_remain,
            cam,
            &mutex,
            &queue,
            &return_array,
        );
    }

    for (promises) |*future| {
        _ = await future;
    } else {
        debug.print("rendering done", .{});
    }
    return return_array;
}

pub fn writePPM(writer: anytype, array: [][]const i64) anyerror!void {
    const w = writer.*;
    const image_width = array.len;
    const image_height = array[0].len;

    try w.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    {
        var j: usize = image_height;
        var i: usize = 0;
        while (0 < j) : (j -= 1) {
            i = 0;
            while (i < image_width) : (i += 1) {
                const c = array[i][j - 1];
                const red = c >> 16 & 0xFF;
                const green = c >> 8 & 0xFF;
                const blue = c & 0xFF;
                try w.print("{d} {d} {d}\n", .{ red, green, blue });
            }
        }
    }
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    var allocator = arena.allocator();

    var buffered_writer = std.io.bufferedWriter(std.io.getStdOut().writer());
    var writer = buffered_writer.writer();

    const config = Config{};

    const array = try render(config, allocator);
    try writePPM(&writer, array);
    try buffered_writer.flush();
    debug.print("writing PPM done", .{});
}
