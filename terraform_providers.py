import os
import json
import subprocess

providersraw = "terraform {\n  required_providers {\n"

if not os.path.exists("providers.json"):
    providers = json.loads("{}")
else:
    providers = json.load(open("providers.json"))

for provider, data in providers.get("providers", {}).items():
    providersraw += f"    {provider} = {{\n      source  = \"{data['source']}\"\n      version = \"{data['version']}\"\n    }}\n"

providersraw += "  }\n}"

if not os.path.exists("data/terraform"):
    os.mkdir("data/terraform")

with open("data/terraform/providers.tf", "w") as f:
    f.write(providersraw)

subprocess.call(["terraform", "init", "-backend=false", "-upgrade"], cwd="data/terraform")
platforms = providers.get("platforms", ["linux_amd64"])
platform_args = [f"-platform={p}" for p in platforms]
subprocess.call(["terraform", "providers", "mirror"] + platform_args + ["../providers"], cwd="data/terraform")