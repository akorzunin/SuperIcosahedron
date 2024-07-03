@tool
extends EditorPlugin

func build() -> bool:

    print("I run before build")
    return true # fail build by return false
