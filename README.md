# devenv-nix
(noun) : idk something clever eventually

## using this approach
- install `direnv` (homebrew on macOS) (allows bypassing `devenv shell` in later runs)
- add to your shell config: `eval "$(direnv hook <shell>)"`
- install nix: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
  - or (and it may be preferable on apple silicon), [here](https://docs.determinate.systems)
- install devenv: `nix profile install --accept-flake-config github:cachix/devenv/latest`
- clone this repo.  
- clone your musiccpr forks and have them sit side by side.  
- copy the three files in this repo to the root of your backeend clone.  

- cd to your backend clone and run `direnv allow`, followed by `devenv shell` to build the shell with deps cached.  
- wait. it can take a minute or three.  
- once it completes you will be placed in a shell environment with everything ready.  
- run `musiccpr-init` to set up the db (redundancies here with deps install)
- run `devenv up` to launch postgres, the backend, and the frontend all at once.
- NOTE: for now due to a likely race you have to select `django` in the tui that appears and reset with `ctrl-r`

You should have the backend, frontend, and db running and talking.  