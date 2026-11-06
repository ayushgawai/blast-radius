import os

import pytest

from features.build import load_events


@pytest.fixture(scope="session")
def events():
    return load_events(os.environ["EVENTS_PATH"])
