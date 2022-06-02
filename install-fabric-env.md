# 在local安裝fabric環境

## **環境安裝**

* apt-get
    ```sh
    sudo apt-get install curl jq git
    ```

* Go
    ```sh
    gozip="go1.15.1.linux-amd64.tar.gz"
    curl -O https://storage.googleapis.com/golang/${gozip}
    sudo tar -C /usr/local -xzf ./${gozip}
    
    file="/home/${USER}/.bashrc"
    echo "" >> ${file}
    echo "#GO VARIABLES" >> ${file}
    echo "export GOROOT=/usr/local/go" >> ${file}
    echo "export GOPATH=~/go" >> ${file}
    echo 'export PATH=$PATH:$GOROOT/bin' >> ${file}
    echo 'export PATH=$PATH:$GOPATH/bin' >> ${file}
    echo "#END GO VARIABLES" >> ${file}
    source ~/.bashrc
    go version
    
    mkdir ~/go && mkdir -p ~/go/src ~/go/pkg ~/go/bin
    ```

* docker
    ```sh
    curl -sSL https://get.docker.com/ | sh
    sudo usermod -aG docker ${USER}
    ```

* docker-compose
  
    ```sh
  sudo curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
    docker-compose version
  ```
  
* 以上安裝完後，**請重新啟動設備**，使docker可正常使用

---

## **建置fabric環境**
**`make sure docker can be used: docker ps -a`**

```sh
# curl -sSL https://bit.ly/2ysbOFE | bash -s -- <fabric_version> <fabric-ca_version>
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.5 1.5.2

# fabric-samples/bin底下
sudo cp * /usr/local/bin
```
