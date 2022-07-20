# Ray-Tracing-in-One-Weekend.zig

[Ray Tracing in One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html) in Zig!

![final image](./image/png/image131.png)

## How to execute

```sh
git clone https://github.com/ryoppippi/Ray-Tracing-in-One-Weekend.zig
zig build -Drelease-fast=true
./zig-out/bin/Ray-Tracing-in-One-Weekend.zig >> image.ppm
```

## Bechmark

- Machine: Mac Mini 2021
- Chip: Apple M1
- Memory: 16GB
- OS: macOS 12.4（21F79）
- Zig: 0.10.0-dev.3007+6ba2fb3db

```sh
________________________________________________________
Executed in  879.32 secs    fish           external
   usr time  863.33 secs   35.00 micros  863.33 secs
   sys time   15.33 secs  550.00 micros   15.33 secs
```

## License

MIT

## Author

Ryotaro "Justin" Kimura (a.k.a. ryoppippi)
