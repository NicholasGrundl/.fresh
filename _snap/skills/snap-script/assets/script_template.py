# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "typer",
#     "loguru",
#     "nanoid",
#     # add domain deps here, e.g. "pandas>=2.2", "matplotlib>=3.8", "seaborn>=0.13"
# ]
# ///
"""One-line purpose of this script.

Example:
    uv run script.py path/to/input.csv --output path/to/output.csv
"""

from __future__ import annotations

import sys
from pathlib import Path

import typer
from loguru import logger
from nanoid import generate

app = typer.Typer(add_completion=False, help="One-line purpose of this script.")

# nanoid alphabet kept to lowercase + digits so suffixes are filename-clean
_HASH_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"


def configure_logging(verbose: bool) -> None:
    """Send loguru to stdout so the invoking agent sees live progress."""
    logger.remove()
    logger.add(
        sys.stdout,
        format="<green>{time:HH:mm:ss}</green> | {level: <7} | {message}",
        level="DEBUG" if verbose else "INFO",
    )


def resolve_output_path(path: Path, clobber: bool) -> Path:
    """Return a non-colliding output path.

    If `clobber` is False and `path` already exists, insert a short random
    nanoid before the extension (e.g. report.csv -> report_a3k9zd.csv).
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    if clobber or not path.exists():
        return path
    suffix = generate(_HASH_ALPHABET, 6)
    return path.with_name(f"{path.stem}_{suffix}{path.suffix}")


@app.command()
def main(
    input_path: Path = typer.Argument(..., help="Path to the input file."),
    output_path: Path = typer.Option(
        None, "--output", "-o", help="Where to write output. Defaults to a derived path."
    ),
    clobber: bool = typer.Option(
        False, "--clobber", help="Overwrite an existing output file instead of writing a new one."
    ),
    verbose: bool = typer.Option(
        False, "--verbose", "-v", help="Enable DEBUG-level logging."
    ),
) -> None:
    """What this script does (shown in --help)."""
    configure_logging(verbose)

    if not input_path.exists():
        logger.error(f"Input not found: {input_path}")
        raise typer.Exit(code=1)

    # Default output derived from input when not supplied.
    if output_path is None:
        output_path = input_path.with_name(f"{input_path.stem}_out{input_path.suffix}")

    logger.info(f"Reading {input_path}")
    # --- do the work here ---
    # result = transform(input_path)

    final_path = resolve_output_path(output_path, clobber)
    logger.debug(f"Resolved output path: {final_path}")
    # --- write the result to final_path here ---
    # result.write(final_path)

    logger.info(f"Wrote {final_path}")


if __name__ == "__main__":
    app()
