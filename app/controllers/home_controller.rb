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

      #biometrics = {"wght"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "hr"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "sys"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "dia"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "bmi"=>{"value"=>"3241", "date"=>"2014-02-05 00:00:00"}, "hght"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "age"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "gluc"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "percbf"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "ldl"=>{"value"=>"41", "date"=>"2014-02-05 00:00:00"}, "hdl"=>{"value"=>"142", "date"=>"2014-02-05 00:00:00"}, "metrate"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "fatmass"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "leanmass"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "tri"=>{"value"=>"142", "date"=>"2014-02-05 00:00:00"}, "bpd"=>{"value"=>"75", "date"=>"2014-01-21 00:00:00"}, "bps"=>{"value"=>"120", "date"=>"2014-01-21 00:00:00"}, "h1c"=>{"value"=>"4.81", "date"=>"2014-01-21 00:00:00"}}
      #risks =  {"entity_id"=>"P5", "date_assessed"=>"2014-01-21 00:00:00", "gendrisk"=>"0", "postmen"=>"0", "depression"=>"0", "agerisk"=>"2", "hxdiabetes"=>"0", "hypertri"=>"1", "hdlrisk"=>"1", "hscprrisk"=>"0", "bprisk"=>"2", "ethnicrisk"=>"0", "pcosrisk"=>"0", "physactrisk"=>"1", "obesityrisk"=>"1", "fruitrisk"=>"2", "meatrisk"=>"0", "dairyrisk"=>"1", "current_risk"=>"1", "smoking"=>"1"}
      #user = {"entity_id"=>"16", "owner_ssn"=>"", "owner_unit_number"=>"0001", "owner_last_name"=>"Hojat", "owner_first_name"=>"12", "owner_mi"=>"", "owner_sex"=>"", "owner_date_of_birth"=>"0000-00-00 00:00:00", "owner_home_address"=>"", "owner_city"=>"", "owner_state"=>"", "owner_zip"=>"", "owner_home_phone"=>"", "owner_work_phone"=>"", "doctor_id"=>"P00001", "username"=>"12", "password"=>"Redacted"}

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
