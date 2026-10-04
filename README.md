# Counter API on Azure App Service

A .NET 8 API with one endpoint, `GET /count`, which returns how many times it has been called. It runs as a Linux container on Azure App Service, with the infrastructure written in Bicep.

The original task is in [ASSIGNMENT.md](ASSIGNMENT.md).

## Repository layout

```
src/        .NET 8 API and Dockerfile
tests/      Unit tests
iac/        Bicep: main.bicep, modules/, parameters/ (dev, prod), bicepconfig.json
Pipelines/  Azure DevOps pipeline: pipeline.yml, build.yml (CI), deploy.yml (CD),
            Templates/, Variables/
```

## Bugs fixed

**Dockerfile**

- `dotnet restore ".\CounterApi.csproj"` used a Windows path separator, so the image failed to build on Linux. Changed to `./CounterApi.csproj`.
- `EXPOSE 5000` didn't match the port the app listens on (8080, the .NET 8 default). Changed to `EXPOSE 8080`.

**Counter**

- `/count` returned 0 on the first call because `CounterService` used a post-increment (`return _counter++;`), which returns the value before adding 1. Changed to a pre-increment (`return ++_counter;`).
- The existing tests only used a mocked service, so they never ran the real counter. Added a test that calls the real `CounterService` and checks the first call returns 1.

## Dockerfile improvements

- Removed the separate `dotnet build` step; `dotnet publish` already builds the project.
- Added a `.dockerignore` so local `bin/` and `obj/` folders aren't copied into the image build.

## Infrastructure

Resources: Log Analytics workspace, Application Insights, Container Registry, Linux App Service plan and a Web App for Containers.

- One module per resource type, each configured from the parameter file. Optional settings fall back to defaults.
- The Web App finds the plan, registry, Application Insights and workspace by key from the parameter file.
- Naming: `<company><project><environment>` with no hyphens, for example `docosoftcounterapidev`, because Container Registry names can't contain hyphens.
- Tags: a shared `environment` tag, plus optional tags per resource.
- The Web App pulls images with its managed identity (AcrPull); the registry admin user is disabled.
- HTTPS only, TLS 1.2, FTP disabled. Logs go to Log Analytics.
- `WEBSITES_PORT=8080` tells App Service which port the container listens on.

| | dev | prod |
|---|---|---|
| App Service plan | B1 | P0V4 |
| Container Registry | Basic | Standard |
| Log retention | 30 days | 90 days |

## CI/CD

The code is on GitHub because Azure DevOps no longer supports public projects; the pipeline runs in Azure DevOps.

One Azure DevOps pipeline (`Pipelines/pipeline.yml`) with CI and CD in separate files:

- **CI** (`build.yml`): runs the unit tests, lints the Bicep and builds the Docker image, in parallel.
- **CD** (`deploy.yml`): deploys to dev, then prod. Each environment deploys the Bicep, pushes the image to its registry, restarts the app and runs a smoke test.
- Pull requests into `main` run CI only. Merges to `main` run CI and CD.
- `main` is protected by a GitHub ruleset: changes go through a pull request, and force pushes and deletion are blocked. Every PR runs the CI stage as a check; in a team setup, that check would also be required to pass before merging.
- Prod requires manual approval (an approval check on the `docosoftcounterapiprod` environment in Azure DevOps).
- Environment-specific values (region, resource group) are in `Pipelines/Variables/<env>.yml`. The Azure DevOps service connection, environment and variable group for each environment are named `docosoftcounterapi<env>`.
- One service connection per environment (`docosoftcounterapidev`, `docosoftcounterapiprod`). In production, each would target its own subscription with access limited to that environment.
- The subscription ID is kept in an Azure DevOps variable group per environment, not in the repository, because the repository is public.
- After deployment, a smoke test calls `/count` twice and checks the value increases by 1. The counter is held in memory, so the pipeline then restarts the app to reset it and the first real request returns 1.

## Trade-offs and assumptions

- **Region:** deployed to UK South because of capacity constraints in West Europe and North Europe.
- **Prod:** P0V4 App Service plan.
- **Single instance:** the app is lightweight (a single counter endpoint), so one instance is enough.
- **Linter warning:** `diagnosticSettings` uses the newest API version available (a preview); the linter warning about it is expected.
