"""Filter AWS raw data."""
import os
from glob import glob

import pandas as pd


def main(input_path, output_path):
    """Filter AWS raw data."""
    raw_files = glob(os.path.join(input_path, "*.json"))

    for raw_file in raw_files:
        region = os.path.basename(raw_file).split(".")[0]
        print(f"Processing {region}...")
        df = pd.read_json(raw_file)
        df.sort_values("ImageId", inplace=True)
        df.drop(columns=["BlockDeviceMappings"], inplace=True)
        df.to_csv(os.path.join(output_path, f"{region}.csv"), index=False)


if __name__ == "__main__":
    main()
