from ..src import __version__


def test_check_version(*args):
    assert __version__ == "0.1.0"