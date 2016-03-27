(function() {
  $(document).ready(function() {
    $("#loginForm").bootstrapValidator({
      message: "填写项不符全要求.",
      feedbackIcons: {
        valid: "glyphicon glyphicon-ok",
        invalid: "glyphicon glyphicon-remove",
        validating: "glyphicon glyphicon-refresh"
      },
      fields: {
        "user[email]": {
          validators: {
            notEmpty: {
              message: "登陆邮箱为必填项."
            },
            emailAddress: {
              message: "邮箱地址无效."
            }
          }
        },
        "user[password]": {
          validators: {
            notEmpty: {
              message: "登陆密码为必填项."
            }
          }
        }
      }
    });
    $("#validateBtn").click(function() {
      return $("#loginForm").bootstrapValidator("validate");
    });
    return $("#resetBtn").click(function() {
      return $("#loginForm").data("bootstrapValidator").resetForm(true);
    });
  });

}).call(this);
