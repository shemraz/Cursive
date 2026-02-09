set shell := ["/bin/nu", "-c"]

@repl:
    julia --project=. --interactive -e 'using Revise; using Cursive;' 
