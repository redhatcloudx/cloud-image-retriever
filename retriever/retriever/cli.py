"""CLI for various operations"""
import click

from retriever import filter_aws


@click.command()
@click.option(
    "--input-path", help="Path to directory with raw AWS JSON files.", required=True
)
@click.option("--output-path", help="Path to write filtered JSON.", required=True)
def filter_aws_data(input_path, output_path):
    """Filter raw AWS data"""
    filter_aws.main(input_path, output_path)
