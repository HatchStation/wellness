class HomeController < ApplicationController

  require 'open-uri'

  def index

  end

  def dashboard
    api = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getdoctorpatients&docid=P00001&username=test1&pw=test1")) rescue {}
    user = {}
    @upcoming_patients = []
    api.each do |id, patient|
      if !patient['Nextappt'].nil? && patient['Nextappt'].any?
        user['name'] = patient['Owner_First_Name']
        user['Appointment_Date'] = patient['Nextappt'].first['Appointment_Date']
        @upcoming_patients.push(user)
        user = {}
      end
    end
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

      risk_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getrisk&eid=#{eid}&pw=#{pw}"))
      risks = downcase_hash(risk_hash.first)

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
        cholesterol_level = 'Desirable'
      elsif (200..240) === total_cholesterol
        chol_color = 'well-yellow'
        cholesterol_level = 'Borderline High'
      elsif total_cholesterol > 240
        chol_color = 'well-red'
        cholesterol_level = 'High'
      else
        chol_color = 'well-white'
        cholesterol_level = ''
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

     @colors = { hba1c_color: hba1c_color, gluc_color: gluc_color, chol_color: chol_color, bps_color: bps_color, bpd_color: bpd_color, cholesterol_level: cholesterol_level }
    else
     redirect_to root_path
    end
  end

  def demo

  end

  def fitness
    id = params[:id].to_i rescue nil
    if id && id > 0

      eid = "P#{id}"
      pw = "PW#{id}"

      fitness_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getactivities&eid=#{eid}&pw=#{pw}&startdate=2013-2-2&enddate=2013-10-10"))
      fitness = downcase_hash(fitness_hash)
      #fitness = {"minutes"=> 1, "calories"=> 5}

      minutes = fitness['minutes'].to_i

      if (0..2) === minutes
        minutes_color = 'well-bg-red'
      elsif (2..4) === minutes
        minutes_color = 'well-bg-yellow'
      elsif minutes > 4
        minutes_color = 'well-bg-green'
      else
        minutes_color = 'well-bg-white'
      end

      calories = fitness['calories'].to_i
      if (0..2) === calories
        calories_color = 'well-bg-red'
      elsif (2..4) === calories
        calories_color = 'well-bg-yellow'
      elsif calories > 4
        calories_color = 'well-bg-green'
      else
        calories_color = 'well-bg-white'
      end

      colors = { minutes_color: minutes_color, calories_color: calories_color }
    else
      fitness = {}
      colors = {}
    end
    render partial: '/home/patient/fitness', locals: { fitness: fitness, we_colors: colors }
  end

  def diet
    id = params[:id].to_i rescue nil
    if id && id > 0

      eid = "P#{id}"
      pw = "PW#{id}"

      d_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getservings&eid=#{eid}&pw=#{pw}&servdateafter=2013-2-2"))
      diet_hash = d_hash.to_a.last.last
      #diet_hash = ['aaa']
      if diet_hash.any?

        diet = downcase_hash(diet_hash)
        #diet = {"fruit"=>4, "veg"=>7, "dairy"=>4, "meat"=>8}

        fruit = diet['fruit'].to_i
        if (0..2) === fruit
          fruit_color = 'well-bg-red'
          fruit_bar = (fruit == 0) ? 0 : (fruit == 1 ? '20' : '40')
        elsif (2..4) === fruit
          fruit_color = 'well-bg-yellow'
          fruit_bar = (fruit == 3) ? 50 : '65'
        elsif fruit > 4
          fruit_color = 'well-bg-green'
          fruit_bar = '90'
        else
          fruit_color = 'well-bg-white'
          fruit_bar = '0'
        end

        veg = diet['veg'].to_i
        if (0..2) === veg
          veg_color = 'well-bg-red'
          veg_bar = (veg == 0) ? 0 : (veg == 1 ? '20' : '40')
        elsif (2..4) === veg
          veg_color = 'well-bg-yellow'
          veg_bar = (veg == 3) ? 50 : '65'
        elsif veg > 4
          veg_color = 'well-bg-green'
          veg_bar = '90'
        else
          veg_color = 'well-bg-white'
          veg_bar = '0'
        end

        dairy = diet['dairy'].to_i
        if (0..2) === dairy
          dairy_color = 'well-bg-red'
          dairy_bar = (dairy == 0) ? 0 : (dairy == 1 ? '20' : '40')
        elsif (2..4) === dairy
          dairy_color = 'well-bg-yellow'
          dairy_bar = (dairy == 3) ? 50 : '65'
        elsif dairy > 4
          dairy_color = 'well-bg-green'
          dairy_bar = '90'
        else
          dairy_color = 'well-bg-white'
          dairy_bar = '0'
        end

        meat = diet['meat'].to_i
        if (0..2) === meat
          meat_color = 'well-bg-green'
          meat_bar = (dairy == 0) ? 0 : (dairy == 1 ? '20' : '40')
        elsif (2..4) === meat
          meat_color = 'well-bg-yellow'
          meat_bar = (dairy == 3) ? 50 : '65'
        elsif meat > 4
          meat_color = 'well-bg-red'
          meat_bar = '90'
        else
          meat_color = 'well-bg-white'
          meat_bar = '0'
        end

        colors = { fruit_color: fruit_color, fruit_bar: fruit_bar, veg_color: veg_color, veg_bar: veg_bar, dairy_color: dairy_color, dairy_bar: dairy_bar, meat_color: meat_color, meat_bar: meat_bar }
      end
      diet ||= {}
      colors ||= {}
    else
      diet = {}
      colors = {}
    end
    render partial: '/home/patient/diet', locals: { diet: diet, we_colors: colors }
  end

  def medication
    id = params[:id].to_i
    if id && id > 0
      eid = "P#{id}"
      pw = "PW#{id}"
      medication = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getmedications&eid=#{eid}&pw=#{pw}"))
      #medication = [{"Medication_Name"=>"Minodidil 10 MG"}, {"Medication_Name"=>"Pharmapan 30 MG"}, {"Medication_Name"=>"Obligupet Powder"}]
    else
      medication = []
    end
    render partial: '/home/patient/medication', locals: { medications: medication }
  end

  def targets
    id = params[:id].to_i
    if id && id > 0
      eid = "P#{id}"
      pw = "PW#{id}"
      targets = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=gettargets&eid=#{eid}&pw=#{pw}"))
      #targets = {"Minutes"=>90, "BP"=>1, "WGHT"=>1, "Fruit"=>4, "Veg"=>4}
    else
      targets = {}
    end
    render partial: '/home/patient/targets', locals: { targets: targets }
    #targets = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=gettargets&eid=P1&pw=PW1"))
  end

  def weight_bmi
    id = params[:id].to_i
    weight_bmi = {}
    bmi_data = []
    weight_data = []

    if id && id > 0
      eid = "P#{id}"
      pw = "PW#{id}"
      wt = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=WGHT")) rescue []
      bmi = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=BMI")) rescue []
      #wt = [{"Entity_ID"=>"P1", "Biometric_Name"=>"WGHT", "Biometric_Value"=>"135", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"A"}]
      #bmi = [{"Entity_ID"=>"P1", "Biometric_Name"=>"BMI", "Biometric_Value"=>"47.81", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"A"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"BMI", "Biometric_Value"=>"49.1", "Biometric_Date"=>"2014-01-11 00:00:00", "Biometric_Source"=>"D"}]

      if wt.any?
        weight_bmi['weight'] = wt.last['Biometric_Value']
        wt.each_with_index do |w, n|
          weight_data.push([n+1, w['Biometric_Value'].to_i])
        end
      end
      weight_bmi['weight_data'] = weight_data

      if bmi.any?
        weight_bmi['body_fat'] = bmi.last['Biometric_Value']
        bmi.each_with_index do |b, n|
          bmi_data.push([n+1, b['Biometric_Value'].to_i])
        end
      end
      weight_bmi['bmi_data'] = bmi_data
    end
    #bmi = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=P1&pw=PW1&whichbio=BMI"))
    render partial: '/home/patient/weight_bmi', locals: { wt_bmi: weight_bmi, bmi_data: bmi_data, weight_data: weight_data }
  end

  def flot_charts

  end

  def calendar
    render partial: '/home/patient/calender'
  end

  def risks

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
