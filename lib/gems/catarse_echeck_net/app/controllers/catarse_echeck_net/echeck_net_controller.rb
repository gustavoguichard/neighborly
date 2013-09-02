class  CatarseEcheckNet::EcheckNetController < ApplicationController
  skip_before_filter :force_http
  layout :false

  def review
  end

  def check_routing_number
    routing_number = RoutingNumber.find_by_number(params[:number])
    if routing_number.present?
      render json: { ok: routing_number.present?, bank_name: routing_number.bank_name }
    else
      render json: { ok: routing_number.present? }
    end
  end

  def pay
    begin
      backer.update_attributes payment_method: 'eCheckNet'

      #NOTE: AuthorizeNet AIM Transacation needs to a new instance every time
      _test = (::Configuration[:test_payments] == 'true')

      an_login_id = ::Configuration[:authorizenet_login_id]
      an_transaction_key = ::Configuration[:authorizenet_transaction_key]
      an_gateway = _test ? :sandbox : :production

      gateway = ::AuthorizeNet::AIM::Transaction.new(an_login_id, an_transaction_key, gateway: an_gateway )

      rn = RoutingNumber.find_by_number(params["routing_number"])
      check = ::AuthorizeNet::ECheck.new(params["routing_number"], params["account_number"], rn.bank_name, params["account_holder_name"])

      response = gateway.purchase(backer.price_with_tax.to_s, check)

      PaymentEngines.create_payment_notification backer_id: backer.id, extra_data: response.inspect

      if response.success?
        backer.update_attribute :payment_id, response.transaction_id
        backer.update_attribute :payment_token, response.transaction_id

        session[:thank_you_id] = backer.project.id
        session[:_payment_token] = backer.payment_token

        flash[:success] = t('projects.backers.checkout.success')

        return render :json => { process_status: 'ok', message: response.fields[:response_reason_text]} if request.xhr?

        redirect_to project_backer_path(backer.project, backer)
      else
        return render :json => { process_status: 'error', message: response.fields[:response_reason_text]} if request.xhr?
        flash[:failure] = response.fields[:response_reason_text]
        redirect_to pay_echeck_net_path(backer)
      end

    rescue Exception => e
      Rails.logger.info "-----> #{e.inspect}"
      flash[:failure] = 'OPS, occour some error when tryed make you payment.'
      return render :json => { process_status: 'error', message: 'OPS, occour some error when tryed make you payment.'} if request.xhr?
      return redirect_to main_app.new_project_backer_path(backer.project)
    end
  end

  protected

  def backer
    @backer ||= if params['id']
                  PaymentEngines.find_payment(id: params['id'])
                end
  end


end
