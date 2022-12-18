<template>
  <div id="json-import">
    <el-dialog
      :title="uploading ? $t('table.json_file_import.uploading_title') : $t('table.credential_file_import.import_title')"
      :visible.sync="dialogVisible" width="30%" :before-close="handleClose">
      <div v-if="!uploading">
        <el-upload class="upload-demo" action="" :show-file-list="false" :before-upload="beforeUpload" drag
                   style="text-align:center">
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">{{ $t('table.json_file_import.upload_text_first') }}
            <em>{{ $t('table.json_file_import.upload_text_second') }}</em></div>
          <div class="el-upload__tip" slot="tip">{{ $t('table.credential_file_import.comment') }}</div>
        </el-upload>
      </div>
      <div v-else>
        <el-progress :text-inside="true" :stroke-width="18" :percentage="percentage"
                     style="margin: 10px 0"></el-progress>
        <div class="result">
          <span style="color:#5FB878; margin-right:15px">{{ success }} success</span>
          <span style="color:#FF5722">{{ error }} error</span>
        </div>
      </div>
      <el-row style="margin:10px 0">
        <el-button size="mini" type="warning" @click="importItems(multipleSelection)" :disabled="multipleSelection.length === 0">{{$t('table.item_search.button_import_item')}}</el-button>
        <el-button size="mini" type="danger" @click="cleanAll()">Clean All</el-button>
      </el-row>
      <el-table border resizable :data="tableItems" tooltip-effect="dark" cell-class-name="table-item"
                style="width: 100%;height:100%;overflow:auto"
                @selection-change="handleSelectionChange" stripe>
        <el-table-column type="selection" :selectable="selectable">
        </el-table-column>
        <el-table-column sortable v-for="header in tableHeaders" :key="header" :prop="header" :label="header"
                         show-overflow-tooltip>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
import {
  LOCAL_STORAGE_DYNAMODB_CONFIGS
} from '@/constants'
import uuid4 from 'uuid/v4'

export default {
  props: {
    visible: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      tableItems: [],
      multipleSelection: [],
      tableHeaders: ['alias', 'region'],
      dialogVisible: false,
      uploading: false,
      success: 0,
      error: 0,
      percentage: 0
    }
  },
  watch: {
    visible(val) {
      this.dialogVisible = val
      if (val) {
        this.uploading = false
        this.percentage = 0
        this.success = 0
        this.error = 0
      }
    }
  },
  methods: {
    cleanAll() {
      this.tableItems = []
    },
    selectable(row, index) {
      return !row.exist
    },
    importItems(rows) {
      if (rows.length <= 0) {
        return
      }
      rows.forEach(credential => {
        let dynamodbConfigs = localStorage.getItem(LOCAL_STORAGE_DYNAMODB_CONFIGS)
        if (!dynamodbConfigs) {
          dynamodbConfigs = []
        } else {
          dynamodbConfigs = JSON.parse(dynamodbConfigs)
        }
        dynamodbConfigs.push(credential)
        localStorage.setItem(LOCAL_STORAGE_DYNAMODB_CONFIGS, JSON.stringify(dynamodbConfigs))
        location.reload()
      })
      this.$message.success(this.$t('message.success.import_success'))
      this.search(this.searchParams, this.type, () => {})
    },
    handleSelectionChange(val) {
      this.multipleSelection = val
    },
    handleClose() {
      this.$emit('close')
    },
    beforeUpload(file) {
      console.log(file)
      this.processFile(file)
      return false
    },
    processFile(file) {
      var r = new FileReader()
      let credentials = []
      let _this = this
      r.onload = function(e) {
        var contents = e.target.result
        contents.split(/[\r?\n]/).forEach(line => {
          if (line.match(/\[.+\]/)) {
            credentials.push({
              'profile': line
            })
          } else {
            let map = line.replace(/\s*/g, '').split('=')
            if (credentials.length > 0 && map.length === 2) {
              credentials[credentials.length - 1][map[0]] = map[1]
            }
          }
        })
        credentials.forEach(credential => {
          let dynamodbConfigs = localStorage.getItem(LOCAL_STORAGE_DYNAMODB_CONFIGS)
          if (!dynamodbConfigs) {
            dynamodbConfigs = []
          } else {
            dynamodbConfigs = JSON.parse(dynamodbConfigs)
          }
          if (credential['profile'] && credential['region'] && credential['aws_access_key_id'] && credential['aws_secret_access_key']) {
            let exist = false
            for (let i = dynamodbConfigs.length - 1; i >= 0; i--) {
              if (dynamodbConfigs[i]['alias'] === credential['profile']) {
                exist = true
                break
              }
            }
            let isGlobal = !['cn-north-1', 'cn-northwest-1'].includes(credential['region'])
            let endpoint = `https://dynamodb.${credential['region']}.amazonaws.com${isGlobal ? '' : '.cn'}`
            let config = {
              'alias': credential['profile'],
              'region': credential['region'],
              'accessKeyId': credential['aws_access_key_id'],
              'secretAccessKey': credential['aws_secret_access_key'],
              'endpoint': endpoint,
              'createdTime': new Date(),
              'id': uuid4(),
              'httpOptions': {
                'connectTimeout': 5000,
                'timeout': 5000
              },
              'maxRetries': 1,
              'exist': exist
            }
            _this.tableItems.push(config)
          }
        })
      }
      r.readAsText(file)
    }
  }
}
</script>

<style lang="sass">
#json-import
  .result
    text-align: center
</style>
