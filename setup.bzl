def maybe(repo, name, **kwargs):
    if not native.existing_rule(name):
        repo(name = name, **kwargs)