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

    if id.to_i > 0
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

      hba1c = biometrics['h1c']['value'].to_i
      if (4..6) === hba1c
        hba1c_color = 'well-green'
      elsif (6..8) === hba1c
        hba1c_color = 'well-orange'
      elsif (8..14) === hba1c
        hba1c_color = 'well-red'
      else
        hba1c_color = 'well-white'
      end

      glucose_fasting = biometrics['gluc']['value'].to_i
      if (80..100) === glucose_fasting
        gluc_color = 'well-green'
      elsif (101..125) === hba1c
        gluc_color = 'well-orange'
      elsif hba1c > 126
        gluc_color = 'well-red'
      else
        gluc_color = 'well-white'
      end


      tri = biometrics['tri']['value'].to_i rescue 0
      hdl = biometrics['hdl']['value'].to_i rescue 0
      ldl = biometrics['ldl']['value'].to_i rescue 0
      total_cholesterol = (tri/5) + (ldl + hdl)

      if total_cholesterol <= 200
        chol_color = 'well-green'
      elsif (200..240) === total_cholesterol
        chol_color = 'well-yellow'
      elsif total_cholesterol > 240
        chol_color = 'well-red'
      else
        chol_color = 'well-white'
      end

      systolic = biometrics['bps']['value'].to_i

      if systolic <= 120
        bps_color = 'well-green'
      elsif (120..140) === systolic
        bps_color = 'well-yellow'
      elsif (140..160) === systolic
        bps_color = 'well-orange'
      elsif systolic > 160
        bps_color = 'well-red'
      else
        bps_color = 'well-white'
      end

      diastolic = biometrics['bpd']['value'].to_i

      if diastolic <= 80
        bpd_color = 'well-green'
      elsif (80..90) === diastolic
        bpd_color = 'well-yellow'
      elsif (90..100) === diastolic
        bpd_color = 'well-orange'
      elsif diastolic > 100
        bpd_color = 'well-red'
      else
        bpd_color = 'well-white'
      end

      @colors = {hba1c_color: hba1c_color, gluc_color: gluc_color, chol_color: chol_color, bps_color: bps_color, bpd_color: bpd_color}
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
