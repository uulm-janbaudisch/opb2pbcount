use bimap::BiMap;
use clap::Parser;
use p2d_opb::{OPBFile, parse};
use std::path::PathBuf;
use std::{fs, io};

#[derive(Parser)]
struct Args {
    /// Where to read the input formula from.
    #[arg(short, long)]
    input: PathBuf,

    /// Where to write the converted formula to.
    #[arg(short, long)]
    output: PathBuf,
}

fn main() -> io::Result<()> {
    let args = Args::parse();
    let input = fs::read_to_string(&args.input)?;
    let mut formula = parse(&input).expect("failed to parse input file");

    convert(&mut formula);

    fs::write(&args.output, formula.to_string())
}

fn convert(formula: &mut OPBFile) {
    let new: BiMap<String, u32> = formula
        .name_map
        .iter()
        .map(|(_name, &index)| (format!("x{}", index + 1), index))
        .collect();

    formula.name_map = new;
}
