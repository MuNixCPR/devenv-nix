# devenv-nix
(noun) : idk something clever eventually

## using this approach
- clone this repo.  
- clone your musiccpr forks and have them sit side by side.  
- copy the three files in this repo to the root of your backeend clone.  

- cd to your backend clone and run `devenv shell` to build the shell with deps cached.  
- wait. it can take a minute or three.  
- once it completes you will be placed in a shell environment with everything ready.  
- run `devenv up` to launch postgres, the backend, and the frontend all at once.
- NOTE: for now due to a likely race you have to select `django` in the tui that appears and reset with `ctrl-r`

You should have the backend, frontend, and db running and talking.  