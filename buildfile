- job:
    name: "sql-kibana-plugin-build"
    triggers:
      - pollscm:
          cron: "*/5 * * * *"
      - github-pull-request:
          build-desc-template: "SQL Kibana Plugin Image Build"
          permit-all: true
          github-hooks: true
          success-status: "Passed"
          failure-status: "Failed"
          status-context: "Build"
          started-status: "Started"
          triggered-status: "Triggered"
    scm:
      - git:
          url: https://github.com/opendistro-for-elasticsearch/sql-kibana-plugin.git
          credentials-id: 415d76b9-a69c-4541-b55c-13ef253ec26b
          branches:
            - "opendistro-1.4"
          wipe-workspace: false
          basedir: "sql-kibana-plugin"
    wrappers:
      - docker-custom-build-env:
          image: 'nanhongy/jsenv:v1'
          image-type: 'pull'
          verbose: true
      - credentials-binding:
          - username-password:
              credential-id: 415d76b9-a69c-4541-b55c-13ef253ec26b
              variable: GIT_CREDENTIALS
    builders:
      - shell: |
          #!/bin/bash -x
          rm -rf kibana
          rm -rf kibana-extra
          KIBANA_VERSION=$(cat sql-kibana-plugin/package.json | grep version | tail -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
          git clone -b $KIBANA_VERSION https://$GIT_CREDENTIALS@github.com/opendistro-for-elasticsearch/kibana-oss.git kibana || 1
          export OLDHOME=$HOME
          export HOME=/jshome
          source /jshome/.bashrc
          export HOME=$OLDHOME
          source /jshome/.nvm/nvm.sh
          cd kibana
          nvm install
          nvm use
          export HOME=/jshome
          mkdir -p ./plugins
          mv ../sql-kibana-plugin ./plugins
          cd ./plugins/sql-kibana-plugin
          yarn kbn bootstrap
          yarn kbn bootstrap
          yarn test:jest
	  yarn build
    image-creaters:
      - build-docker-image:
          type: build
          woring_directory: ./
	  image_name: sql-console-preview
          tag: "test"
          dockerfile: Dockerfile
