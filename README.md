# holochain req/s benchmark

# Reproducing the benchamrk

## 1. Run a node

To run a first node, run `make`

The program will complain that alice's key does not match the one in the config (and give you alice's public key in the logs). Copy it from the logs into `.config/.env` (the file should have been created for you)
Run `make` again. This time the program will complain about bob's public key. Do the same, copy it from the logs and into `.config/.env`

Now if you relaunch `make` the node should run all right.

## 2. Run the benchmark

From another new terminal, run `make bench`
