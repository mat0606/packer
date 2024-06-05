# Build Linux Image for Trade Show

1. Copy the `.env.example` to `.env` and update the values with yours.

    ```console
    cp .env.example .env
    ```

1. Source the envvars

    ```console
    source .env
    ```

1. Initialize Packer using the desired build file

    ```console
    packer init ubuntu2204.pkr.hcl
    ```

1. Build a trade show image using the build called `tradeshow` followed by the filename for the required OS (ubuntu2004.pkr.hcl | ubuntu2204.pkr.hcl)

    ```console
    packer build -only="tradeshow.*" ubuntu2204.pkr.hcl
    ```

1. The previous command will create an image called `tradeshow-packer-ubuntu<22.04 | 20.04>-dev` on your AHV Image Service.
