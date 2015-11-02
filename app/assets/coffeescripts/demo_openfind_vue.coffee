checkTemplate = (element) ->
  membersForm = new Vue(
    el: element
    data:
      btn_disabled: true
      warning_text: ""
      official_url: ""
      input_url: ""
    methods:
      checkUrl: (e) ->
        regexp = new RegExp("^" + @official_url)
        if regexp.test(@input_url)
          @btn_disabled = false
          @warning_text = ""
        else
          @btn_disabled = true
          @warning_text = "输入链接的域名不正确..."
      showLoading: (e) ->
        App.showLoading "处理中..."
        @input_url = ""
        @btn_disabled = true
  )

Vue.directive "disable", (value) ->
  @el.disabled = !!value

checkTemplate "#membersForm"
checkTemplate "#templateForm"