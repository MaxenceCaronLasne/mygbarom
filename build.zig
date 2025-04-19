const std = @import("std");

pub fn build(b: *std.Build) void {
    var target = std.Target.Query{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm7tdmi },
        .os_tag = .freestanding,
    };

    target.cpu_features_add.addFeature(@intFromEnum(std.Target.arm.Feature.thumb_mode));
    const optimize = .ReleaseSmall;

    const exe = b.addExecutable(.{
        .name = "out",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
    });

    exe.setLinkerScript(.{ .src_path = .{
        .owner = b,
        .sub_path = "gba.ld",
    } });

    const objcopy_step = exe.addObjCopy(.{ .format = .bin });
    const install_bin_step = b.addInstallBinFile(objcopy_step.getOutput(), "out.gba");
    install_bin_step.step.dependOn(&objcopy_step.step);

    b.getInstallStep().dependOn(&install_bin_step.step);

    const run_cmd = b.addSystemCommand(&.{ "mgba", b.getInstallPath(.bin, "out.gba") });
    const run_step = b.step("run", "Run the ROM in mGBA emulator");
    run_step.dependOn(&run_cmd.step);
}
