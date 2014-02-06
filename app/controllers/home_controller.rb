class HomeController < ApplicationController

  require 'open-uri'

  def index

  end

  def patient
    eid = params[:eid]
    pw = params[:pw]
    username = params[:username]
    upw = params[:upw]

    if eid && pw && username && upw
      biometrics = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}"))
      sleep 0.1
      risks = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getrisk&eid=#{eid}&pw=#{pw}"))
      sleep 0.1
      user = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=retrieve&username=#{username}&pw=#{upw}"))

      @patient = { biometrics: biometrics, risks: risks.first, user: user }
    else
     redirect_to root_path
    end
  end

  def demo

  end
end
