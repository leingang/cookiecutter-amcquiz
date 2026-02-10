import sys

if __name__ == "__main__":
    args = " ".join(sys.argv[1:])
    print(
        f"""
WARNING: This cookiecutter has been archived.
The current version is in the 
`cookiecutter-coursedocs` repository.

Consider using:

  cookiecutter https://github.com/leingang/\
cookiecutter-coursedocs --directory=nyuquiz {args}
    """
    )
