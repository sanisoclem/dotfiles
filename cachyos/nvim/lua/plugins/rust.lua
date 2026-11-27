-- Stable's rust-analyzer (1.98.1) panics on encase's #[derive(ShaderType)].
-- Run nightly's directly, not via `rustup run`, so cargo and rustc stay on the project's toolchain.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        cmd = { vim.fn.expand("~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer") },
      },
    },
  },
}
