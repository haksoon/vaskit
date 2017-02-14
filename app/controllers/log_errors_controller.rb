class LogErrorsController < ApplicationController
  # POST /log_errors.json
  def create
    obj = params[:obj]
    href = params[:href]
    ua = request.headers['User-Agent'] ? request.headers['User-Agent'] : 'unknown'
    msg = params[:msg]
    url = params[:url]
    line = params[:line]
    col = params[:col]

    if current_user
      log = LogError.create(user_id: current_user.id,
                            error: obj,
                            error_href: href,
                            user_agent: ua,
                            error_message: msg,
                            error_url: url,
                            error_line: line,
                            error_col: col)
    else
      set_visitor
      log = LogError.create(visitor_id: @visitor.id,
                            error: obj,
                            error_href: href,
                            user_agent: ua,
                            error_message: msg,
                            error_url: url,
                            error_line: line,
                            error_col: col)
    end
    AdminMailer.delay.client_error(log)
    render json: {}
  end
end
