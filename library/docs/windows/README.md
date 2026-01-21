# Background

Occaisionally it is preferable to work directly in windows...this has gotten MUCH easier in the last few years.

For example if you need to access COMs or wrap excel its easier in windows


## Environment

This project uses PowerShell scripts to manage Python dependencies within Conda environments.

### Prerequisites

- Windows operating system
- PowerShell
- Anaconda or Miniconda installed
- Git installed

### Miniconda

To install Miniconda on Windows, follow these steps:

1. Download the Miniconda installer from the [official website](https://docs.conda.io/en/latest/miniconda.html).
2. Run the installer executable.
3. Follow the prompts in the installer.
4. Select the "Just Me" option when asked to choose the installation type.
5. Choose the installation directory (e.g., `C:\Miniconda3`) and click "Next".
6. Select the "Add Miniconda3 to my PATH environment variable" option and click "Install".
7. Wait for the installation to complete.
8. After the installation is finished, open a new PowerShell window to verify that Miniconda is installed correctly by running the following command:
   ```
   conda --version
   ```
   If the command displays the version number, Miniconda is installed successfully.

Note: You may need to restart your computer for the changes to take effect.

### conda environment

To begin initialize the conda env for windows.
```
conda init powershell
```

> Note you may need to enable privileges for this to work
> - Check current privileges with `Get-ExecutionPolicy`
> - Change privleges (as admin) with `Set-ExecutionPolicy RemoteSigned`

Next make a new conda environment for your project. This isolates the python package versions installed for the project and maintainsd a consistent python version. 

```
conda create --name `your_environment_name` python=3.10 pip
```

### Git

We will use git to manage versions

First check if you hgave git installed
```
where.exe git
```

If not download git for windows (https://git-scm.com/download/win)


### SSH 

We need to manage SSH persistence in windows powershell to use git.
- see the setup files for doing this. you will need admin access


### Python packages

In order to install packages you will need a `requirements.txt` file

#### Installing Dependencies

1. Open PowerShell
2. Navigate to the project directory
3. Activate your Conda environment:
   ```
   conda activate `your_environment_name`
   ```
4. Run the installation script:
   ```
   .\install_dependencies.ps1
   ```

This will install all packages listed in `requirements.txt` and create a `requirements-lock.txt` file with pinned versions.

#### Uninstalling Dependencies

To remove all installed packages:

1. Open PowerShell
2. Navigate to the project directory
3. Activate your Conda environment:
   ```
   conda activate `your_environment_name`
   ```
4. Run the uninstallation script:
   ```
   .\uninstall_dependencies.ps1
   ```

This will uninstall all pip packages in the current environment and remove the `requirements-lock.txt` file.

