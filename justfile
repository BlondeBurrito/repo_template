# very useful command line runner - https://github.com/casey/just
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]
alias c := clippy
alias d := doc
alias db := debug
alias t := test
alias b := build
alias r := run
alias clogu := changelog-unreleased
alias clog := changelog
# alias cn := clean

bt := '0'

export RUST_BACKTRACE := bt

# print recipes
default:
  just --list
# lint the code aggressively
clippy:
  cargo clippy --workspace --all-targets --all-features
# run a chosen example
example NAME:
  cargo run --release --example {{NAME}} --all-features
# run benchmarks
bench:
  cargo bench -q --benches --workspace --all-features
# run a particular benchmark
bench-one BENCH:
  cargo bench --benches --workspace --all-features {{BENCH}}
# save each benchmark, this should be run on the main branch for comparing with your own branch
bench-save-main:
  cargo bench -q --bench calc_route --workspace --all-features -- --save-baseline main_calc_route
  cargo bench -q --bench calc_flow_open --workspace --all-features -- --save-baseline main_calc_flow_open
  cargo bench -q --bench calc_flow_maze --workspace --all-features -- --save-baseline main_calc_flow_maze
  cargo bench -q --bench init_bundle --workspace --all-features -- --save-baseline main_init_bundle
  cargo bench -q --bench init_cost_fields --workspace --all-features -- --save-baseline main_init_cost_fields
  cargo bench -q --bench init_portals --workspace --all-features -- --save-baseline main_init_portals
  cargo bench -q --bench init_portal_graph --workspace --all-features -- --save-baseline main_init_portal_graph
# compare each benchmark against a saved bench taken from main
bench-compare:
  cargo bench -q --bench calc_route --workspace --all-features -- --baseline main_calc_route
  cargo bench -q --bench calc_flow_open --workspace --all-features -- --baseline main_calc_flow_open
  cargo bench -q --bench calc_flow_maze --workspace --all-features -- --baseline main_calc_flow_maze
  cargo bench -q --bench init_bundle --workspace --all-features -- --baseline main_init_bundle
  cargo bench -q --bench init_cost_fields --workspace --all-features -- --baseline main_init_cost_fields
  cargo bench -q --bench init_portals --workspace --all-features -- --baseline main_init_portals
  cargo bench -q --bench init_portal_graph --workspace --all-features -- --baseline main_init_portal_graph
# run a debug build so the compiler can call out overflow errors etc, rather than making assumptions
debug:
  cargo build --workspace --all-features
# run tests
test: debug
  cargo test --release --workspace --all-features
# generate documentation
doc:
  cargo doc --release --workspace --all-features
# build release bin/lib
build: test doc
  cargo build --release --workspace --all-features --package repo_template
# build and execute bin
run: build
  cargo run --release --package repo_template
# delete `target` directory
clean:
  cargo clean
# git push with a message and optional branch target
push MESSAGE +BRANCH='main':
  git add .
  git commit -m "{{MESSAGE}}"
  git push origin {{BRANCH}}
# generate a changelog with git-cliff-based on conventional commits
changelog-unreleased:
  git cliff -u -p CHANGELOG.md
# generate a changelog with git-cliff-based on conventional commits
changelog TAG:
  git cliff --tag {{TAG}} --output CHANGELOG.md
# evaluate documentation coverage
doc-coverage:
  $env:RUSTDOCFLAGS="-Z unstable-options --show-coverage"
  cargo +nightly doc --workspace --all-features --no-deps --release
  # https://github.com/rust-lang/rust/issues/58154
# evaluate test coverage
code-coverage:
  cargo tarpaulin --release --workspace --all-features --include-tests --engine=llvm --ignore-panics
# install the crate from the local source rather than remote
install:
  cargo install --path .
# Useful tools
dev-tools:
  cargo install loc;
  cargo install git-cliff;
  cargo install blondie;
  cargo install flamegraph;
  cargo install cargo-bloat;
  cargo install cargo-deadlinks;
  cargo install cargo-geiger;
  cargo install cargo-modules;
  cargo install --locked cargo-outdated;
  cargo install cargo-watch;
  cargo install hyperfine;
  cargo install rust-script;
  rust-script --install-file-association;
  cargo install --locked cargo-deny
  cargo install cargo-tarpaulin
# Generate a diagram from a puml file under ./docs/png
diagram NAME:
  java -jar "C:\ProgramData\chocolatey\lib\plantuml\tools\plantuml.jar" docs/png/{{NAME}}.puml
# Generate all puml diagrams under ./docs/png
diagrams:
  ForEach ($i in Get-ChildItem -Path "./docs/png/*.puml") {java -jar "C:\ProgramData\chocolatey\lib\plantuml\tools\plantuml.jar" $i.FullName}