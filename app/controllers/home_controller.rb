class HomeController < ApplicationController

  require 'open-uri'

  def index

  end

  def patient
    id = params[:id]

    eid = "P#{id}"
    pw = "PW#{id}"
    username = "#{id}"
    upw = username

    if eid && pw && username && upw
      bio_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}"))
      biometrics = downcase_hash(bio_hash)
      sleep 0.1

      risk_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getrisk&eid=#{eid}&pw=#{pw}"))
      risks = downcase_hash(risk_hash.first)
      sleep 0.1

      user_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=retrieve&username=#{username}&pw=#{upw}"))
      user = downcase_hash(user_hash)

      @patient = { biometrics: biometrics, risks: risks, user: user }
    else
     redirect_to root_path
    end
  end

  def demo

  end

  private

  def downcase_hash(hash)
    new_hash = {}
    hash.to_hash.each_pair do |k,v|
      new_hash.merge!({k.downcase => v})
    end
    return new_hash
  end
end
