"""Filter AWS raw data."""
# pylint: disable=no-member
import os
from glob import glob

import pandas as pd


def read_data(input_path):
    """Read data from input path."""
    raw_files = glob(os.path.join(input_path, "*.json"))

    dataframes = []
    for raw_file in raw_files:
        region = os.path.basename(raw_file).split(".")[0]
        print(f"Processing {region}...")

        raw_df = pd.read_json(raw_file, orient="records")
        raw_df.sort_values("ImageId", inplace=True)

        # Save some disk space.
        raw_df.drop(columns=["BlockDeviceMappings", "ImageLocation"], inplace=True)

        # Add the region column.
        raw_df["Region"] = region

        dataframes.append(raw_df)

    return pd.concat(dataframes)


def filter_by_owner(image_df, output_path):
    """Filter by owner."""
    print("Writing filtered files...")

    output_dir = os.path.join(output_path, "aws", "owner")
    os.makedirs(output_dir, exist_ok=True)

    for owner_id in image_df["OwnerId"].unique():
        output_json = os.path.join(output_dir, f"{owner_id}")
        owner_df = image_df[image_df["OwnerId"] == owner_id]

        # Skip owners with less than 50 images.
        if len(owner_df.index) < 50:
            continue

        owner_df.to_json(output_json, orient="records", indent=2)


def main(input_path, output_path):
    """Filter AWS raw data."""
    image_df = read_data(input_path)
    filter_by_owner(image_df, output_path)
