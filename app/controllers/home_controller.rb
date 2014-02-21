class HomeController < ApplicationController

  require 'open-uri'

  def index

  end

  def dashboard
    api = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getdoctorpatients&docid=P00001&username=test1&pw=test1")) rescue {}
    #api = []
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
      bio_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}")) rescue {}
      biometrics = downcase_hash(bio_hash)

      risk_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getrisk&eid=#{eid}&pw=#{pw}")) rescue {}
      risks = downcase_hash(risk_hash.first)

      user_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=retrieve&username=#{username}&pw=#{upw}")) rescue {}
      user = downcase_hash(user_hash)

      #biometrics = {"wght"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "hr"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "sys"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "dia"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "bmi"=>{"value"=>"3241", "date"=>"2014-02-05 00:00:00"}, "hght"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "age"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "gluc"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "percbf"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "ldl"=>{"value"=>"41", "date"=>"2014-02-05 00:00:00"}, "hdl"=>{"value"=>"142", "date"=>"2014-02-05 00:00:00"}, "metrate"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "fatmass"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "leanmass"=>{"value"=>"0", "date"=>"2014-02-05 00:00:00"}, "tri"=>{"value"=>"142", "date"=>"2014-02-05 00:00:00"}, "bpd"=>{"value"=>"75", "date"=>"2014-01-21 00:00:00"}, "bps"=>{"value"=>"120", "date"=>"2014-01-21 00:00:00"}, "h1c"=>{"value"=>"4.81", "date"=>"2014-01-21 00:00:00"}}
      #risks =  {"entity_id"=>"P5", "date_assessed"=>"2014-01-21 00:00:00", "gendrisk"=>"0", "postmen"=>"0", "depression"=>"0", "agerisk"=>"2", "hxdiabetes"=>"0", "hypertri"=>"1", "hdlrisk"=>"1", "hscprrisk"=>"0", "bprisk"=>"2", "ethnicrisk"=>"0", "pcosrisk"=>"0", "physactrisk"=>"1", "obesityrisk"=>"1", "fruitrisk"=>"2", "meatrisk"=>"0", "dairyrisk"=>"1", "current_risk"=>"1", "smoking"=>"1"}
      #user = {"entity_id"=>"16", "owner_ssn"=>"", "owner_unit_number"=>"0001", "owner_last_name"=>"Hojat", "owner_first_name"=>"12", "owner_mi"=>"", "owner_sex"=>"", "owner_date_of_birth"=>"0000-00-00 00:00:00", "owner_home_address"=>"", "owner_city"=>"", "owner_state"=>"", "owner_zip"=>"", "owner_home_phone"=>"", "owner_work_phone"=>"", "doctor_id"=>"P00001", "username"=>"12", "password"=>"Redacted"}

      @patient = { biometrics: biometrics, risks: risks, user: user }

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

     @colors = { chol_color: chol_color, cholesterol_level: cholesterol_level }
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

      fitness_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getactivities&eid=#{eid}&pw=#{pw}&startdate=2013-2-2&enddate=2013-10-10")) rescue {}
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

      d_hash = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getservings&eid=#{eid}&pw=#{pw}&servdateafter=2013-2-2")) rescue {}
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
      medication = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getmedications&eid=#{eid}&pw=#{pw}")) rescue []
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
      targets = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=gettargets&eid=#{eid}&pw=#{pw}")) rescue {}
      #targets = {"Minutes"=>90, "BP"=>1, "WGHT"=>1, "Fruit"=>4, "Veg"=>4}
    else
      targets = {}
    end
    render partial: '/home/patient/targets', locals: { targets: targets }
    #targets = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=gettargets&eid=P1&pw=PW1"))
  end

  def flot_charts
    id = params[:id].to_i
    weight_bmi = {}
    bmi_data = []
    weight_data = []
    blood_sugar = {}
    blood_pressure = {}
    if id && id > 0
      eid = "P#{id}"
      pw = "PW#{id}"

      ## Weight and BMI Partial logic ##

      wt = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=WGHT")) rescue []
      bmi = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=BMI")) rescue []
      #wt = [{"Entity_ID"=>"P1", "Biometric_Name"=>"WGHT", "Biometric_Value"=>"135", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"A"}]
      #bmi = [{"Entity_ID"=>"P1", "Biometric_Name"=>"BMI", "Biometric_Value"=>"47.81", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"A"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"BMI", "Biometric_Value"=>"49.1", "Biometric_Date"=>"2014-01-11 00:00:00", "Biometric_Source"=>"D"}]

      if wt.any?
        weight_bmi['weight'] = wt.last['Biometric_Value']
        # Collecting data for plotting graph
        wt.each_with_index do |w, n|
          weight_data.push([n+1, w['Biometric_Value'].to_i])
        end
      end
      weight_bmi['weight_data'] = weight_data

      if bmi.any?
        weight_bmi['body_fat'] = bmi.last['Biometric_Value']
        # Collecting data for plotting graph
        bmi.each_with_index do |b, n|
          bmi_data.push([n+1, b['Biometric_Value'].to_i])
        end
      end
      weight_bmi['bmi_data'] = bmi_data
      @weight_bmi = weight_bmi


      ## Blood Sugar Partial logic ##

      h1c = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=h1c")) rescue []
      gluc = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=GLUC")) rescue []
      #h1c = [{"Entity_ID"=>"P1", "Biometric_Name"=>"h1c", "Biometric_Value"=>"4.51", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"h1c", "Biometric_Value"=>"7.08", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"h1c", "Biometric_Value"=>"5.72", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"h1c", "Biometric_Value"=>"6.15", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"h1c", "Biometric_Value"=>"6.37", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}]
      #gluc = [{"Entity_ID"=>"P1", "Biometric_Name"=>"GLUC", "Biometric_Value"=>"84", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"A"}]

      if h1c.any?
        hba1c = h1c.last['Biometric_Value'].to_i
        blood_sugar['hba1c'] = hba1c
        if (4..6) === hba1c
          hba1c_color = 'well-green'
        elsif (6..8) === hba1c
          hba1c_color = 'well-orange'
        elsif (8..14) === hba1c
          hba1c_color = 'well-red'
        else
          hba1c_color = 'well-white'
        end
        blood_sugar['hba1c_color'] = hba1c_color

        # Collecting data for plotting graph
        h1c_data = []
        h1c.each_with_index do |h, n|
          h1c_data.push([n+1, h['Biometric_Value'].to_f])
        end
        blood_sugar['h1c_data'] = h1c_data
      end

      if gluc.any?
        glucose = gluc.last['Biometric_Value'].to_i
        blood_sugar['glucose'] = glucose
        if (80..100) === glucose
          gluc_color = 'well-green'
        elsif (101..125) === glucose
          gluc_color = 'well-orange'
        elsif glucose > 126
          gluc_color = 'well-red'
        else
          gluc_color = 'well-white'
        end
        blood_sugar['gluc_color'] = gluc_color

        # Collecting data for plotting graph
        gluc_data = []
        gluc.each_with_index do |g, n|
          gluc_data.push([n+1, g['Biometric_Value'].to_f])
        end
        blood_sugar['gluc_data'] = gluc_data
      end
      @blood_sugar = blood_sugar
      #raise @blood_sugar.inspect


      ## Blood Pressure Partial Logic ##

      bps = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=bps")) rescue []
      bpd = JSON.load(open("http://www.xeossolutions.com/wellmed.php?action=getbiometrics&eid=#{eid}&pw=#{pw}&whichbio=bpd")) rescue []
      #bps = [{"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"130", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"167", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"98", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"142", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"126", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bps", "Biometric_Value"=>"164", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}]
      #bpd = [{"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"88", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"94", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"62", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"105", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"72", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}, {"Entity_ID"=>"P1", "Biometric_Name"=>"bpd", "Biometric_Value"=>"103", "Biometric_Date"=>"2014-01-21 00:00:00", "Biometric_Source"=>"V"}]

      if bps.any?
        systolic = bps.last['Biometric_Value'].to_i
        blood_pressure['systolic'] = systolic

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
        blood_pressure['bps_color'] = bps_color

        # Collecting data for plotting graph
        bps_data = []
        bps.each_with_index do |s, n|
          bps_data.push([n+1, s['Biometric_Value'].to_i])
        end
        blood_pressure['bps_data'] = bps_data

      end

      if bpd.any?
        diastolic = bpd.last['Biometric_Value'].to_i
        blood_pressure['diastolic'] = diastolic

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
        blood_pressure['bpd_color'] = bpd_color

        # Collecting data for plotting graph
        bpd_data = []
        bpd.each_with_index do |s, n|
          bpd_data.push([n+1, s['Biometric_Value'].to_i])
        end
        blood_pressure['bpd_data'] = bpd_data
      end

      @blood_pressure = blood_pressure
    end
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
