.DEFAULT_GOAL:dev
dev: deps gen-keys build
	holochain -c .cache/hcconfig.gen.toml
build:
	hc package -o ${DNA_FILE_PATH}
	@tera -f hcconfig.tpl.toml --env > .cache/hcconfig.gen.toml
addnode: deps gen-keys build
	@tera -f hcconfig.n2.tpl.toml --env > .cache/hcconfig.n2.gen.toml
	holochain -c .cache/hcconfig.n2.gen.toml


POST-/info-instances:
	${jsonRPC} -d '{"jsonrpc": "2.0","id": "0","method": "info/instances"}'
POST-/create-entry:
	${jsonRPC} -d '{"jsonrpc":"2.0","method":"call","params":{"instance_id":"instance_alice","zome":"zome_a","function":"create_my_entry","args":{"entry":{"content":"sample content"}}},"id":4}'
bench:
	drill --benchmark test/benchmark.yml --stats
BOOTSTRAP-POST-/info-instances:
	${bstrapJsonRPC} -d '{"jsonrpc": "2.0","id": "0","method": "info/instances"}'



deps: rust-version dirs
	@tera --version | grep 0.1.1 $s || cargo install tera-cli --version 0.1.1
	@holochain --version | grep 0.0.23-alpha1 $s || cargo install holochain --force --git https://github.com/holochain/holochain-rust.git --tag v0.0.23-alpha1
	@hc --version | grep 0.0.23-alpha1 $s || cargo install hc --force --git https://github.com/holochain/holochain-rust.git --tag v0.0.23-alpha1
	@drill --version | grep 0.5.0 $s || cargo install drill --version 0.5.0
dirs:
	@mkdir -p $(dir ${DNA_FILE_PATH}) .config && cat .config/.env $s || echo "KEY_ALICE=XXXX\nKEY_BOB=XXXX\nKEY_BOOTSTRAP_AGENT=''" > .config/.env
	@mkdir -p /tmp/hc/network/${DNA_HASH}
gen-keys: deps
	@mkdir -p ${KEYS_DIR} $s && cat ${KEYS_DIR}/alice.key $s || hc keygen -n --path ${KEYS_DIR}/alice.key
	@mkdir -p ${KEYS_DIR} $s && cat ${KEYS_DIR}/bob.key $s || hc keygen -n --path ${KEYS_DIR}/bob.key
	@mkdir -p ${KEYS_DIR} $s && cat ${KEYS_DIR}/charlie.key $s || hc keygen -n --path ${KEYS_DIR}/charlie.key
rust-version:
	@rustup default | grep nightly-2019-01-24 $s || rustup default nightly-2019-01-24
install-rust: 		# install manually: build-essential, pkg-config
	@rustup --version $s || curl https://sh.rustup.rs -sSf | sh -s -- -y
	@rustup show |grep wasm32-unknown-unknown $s || rustup target add wasm32-unknown-unknown

userDir = $(shell echo ${HOME})
export KEYS_DIR = ${userDir}/.cache/hc/keys
export DNA_FILE_PATH = .cache/dist/zome.dna.json
export DNA_HASH = $(shell hc hash -p ${DNA_FILE_PATH} | grep -o '\bQm\w*\b'  || echo X)
s = 2>&1 >/dev/null # silence command
jsonRPC = curl -X POST http://localhost:4000 --header 'content-type: application/json'
bstrapJsonRPC = curl -X POST http://84.113.29.160:4000 --header 'content-type: application/json'
# load dot-env
-include .config/.env
export




