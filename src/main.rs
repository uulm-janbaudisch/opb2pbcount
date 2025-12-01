use bimap::BiMap;
use clap::Parser;
use p2d_opb::{Equation, EquationKind, OPBFile, parse};
use std::path::PathBuf;
use std::process::exit;
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
    // Rename variables to x1, x2, ...
    let new: BiMap<String, u32> = formula
        .name_map
        .iter()
        .map(|(_name, &index)| (format!("x{}", index + 1), index))
        .collect();

    formula.name_map = new;

    // Fail on `!=` constraint, as pbcount can't handle it.
    if formula
        .equations
        .iter()
        .any(|equation| equation.kind == EquationKind::NotEq)
    {
        eprintln!("pbcount can't handle `!=` constraints, exiting.");
        exit(1);
    }

    // Change each constraint to be either `>=` or `=`.
    formula.equations.iter_mut().for_each(|equation| {
        match equation.kind {
            // `<=` -> `>=` by multiplying with `-1`.
            EquationKind::Le => invert_le(equation),
            // `<` -> `<=` by subtracting `1` from the right side.
            EquationKind::L => {
                equation.rhs -= 1;
                equation.kind = EquationKind::Le;
                invert_le(equation);
            }
            // `>` -> `>=` by adding `1` to the right side.
            EquationKind::G => {
                equation.rhs += 1;
                equation.kind = EquationKind::Ge;
            }
            // `>=` and `=` can stay.
            _ => {}
        }
    });
}

fn invert_le(equation: &mut Equation) {
    equation.lhs.iter_mut().for_each(|summand| {
        summand.factor *= -1;
    });

    equation.rhs *= -1;
    equation.kind = EquationKind::Ge;
}
