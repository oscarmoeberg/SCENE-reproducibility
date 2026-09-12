"""Execute paper notebooks with the active Python environment, saving copies under tmp/."""
import argparse
import sys
from pathlib import Path

import nbformat
from jupyter_client import KernelManager
from nbclient import NotebookClient


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("notebooks", type=Path, nargs="+")
    parser.add_argument("--timeout", type=int, default=3600, help="Maximum seconds per cell")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = root / "tmp" / "executed"
    output.mkdir(parents=True, exist_ok=True)
    for path in args.notebooks:
        path = path.resolve()
        notebook = nbformat.read(path, as_version=4)
        manager = KernelManager(kernel_name="python3")
        manager.kernel_spec.argv = [sys.executable, "-m", "ipykernel_launcher", "-f", "{connection_file}"]
        client = NotebookClient(notebook, km=manager, timeout=args.timeout,
                                resources={"metadata": {"path": str(root)}})
        print(f"Executing {path.name}", flush=True)
        try:
            client.execute()
        finally:
            nbformat.write(notebook, output / path.name)
            if manager.has_kernel:
                manager.shutdown_kernel(now=True)
        print(f"Completed {path.name}", flush=True)


if __name__ == "__main__":
    main()
