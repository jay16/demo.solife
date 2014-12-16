module HomeHelper
  def chk_params(tea_id)
    # generate static in lib/task
    # NameError: undefined local variable or method `params' for main:Object
    params = params || {}
    params[:tea] && params[:tea].to_i == tea_id ? 1 : 0
  end
end
