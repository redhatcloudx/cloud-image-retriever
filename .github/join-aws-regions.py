#!/usr/bin/env python
from glob import glob
from os.path import basename

import pandas as pd

def get_regions() -> list:
    """Get the regions from the data."""
    return [basename(x).split(".")[0] for x in glob("output/*.json")]


def read_json(region: str) -> pd.DataFrame:
    """Read the json data for a region."""
    filename = f"output/{region}.json"
    temp_df = pd.read_json(filename, orient="records")

    # Create a view of the data.
    schema_fields = [
        "ImageId",
        "OwnerId",
        "Name",
        "Architecture",
        "VirtualizationType",
        "CreationDate",
    ]
    region_view = temp_df[schema_fields].copy()

    # Add the region to the view.
    region_view["Region"] = region
    return region_view


def write_json(amis_df: pd.DataFrame) -> None:
    """Write the json data for a region."""
    amis_df.to_json("index.json", orient="records")
    return None

if __name__ == "__main__":
    # Read in all the data frames and concatenate them.
    data_frames = [read_json(region) for region in get_regions()]
    df = pd.concat(data_frames, ignore_index=True)

    # Sort by CreationDate, just because.
    df.sort_values(by=["CreationDate"], inplace=True)

    # Write the data to a json file.
    write_json(df)