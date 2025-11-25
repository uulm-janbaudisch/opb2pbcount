# opb2pbcount

> Converter for the OPB format to be used by pbcount

This tool takes an OPB file and modifies it in such a way that it can be consumed by [pbcount][pbcount].
Specifically, pbcount only accepts variables in the form of `x1`, `x2`, ...

## Installation

### [Nix][nix]

```
nix build github:uulm-janbaudisch/opb2pbcount
```

### Cargo

```
cargo build --release
```

## Usage

```
opb2pbcount --input file.opb --output output.opb
```

[pbcount]: https://github.com/grab/pbcount
[nix]: https://nixos.org
