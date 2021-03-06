class Trial < ActiveRecord::Base
	validates :title, :description, :sponsor, :focus, presence: true
	validates :nct_id, uniqueness: true
	before_save :enumerate_age_value
	
	scope :control?, -> (vt) {
		if vt == "control"
			where(healthy_volunteers: "Accepts Healthy Volunteers")
		end 
	}
	scope :gender, -> (gender) {
		if gender == "male"
			where(gender: ["Male", "Both"])
		elsif gender == "female"
			where(gender: ["Female", "Both"])

		end 
	}
	scope :search_for, -> (query) {
		where('title ILIKE :query OR description ILIKE :query', query: "%#{query}%")
		#where('originalminage ILIKE :query OR originalmaxage ILIKE :query', query: "%#{query}%")
	}


	scope :age, -> (age){
		unless age.blank?
			where("minimum_age <= ? and maximum_age >= ?", age, age)
		end
	}

	scope :type, -> (type){
		unless type == "all" || type.blank?
			if type == "int"
				where(study_type: "Interventional")
			elsif type == "obs"
				where(study_type: ["Observational","Observational [Patient Registry]"])
			end	
		end
	}

	scope :phase, -> (phase){
		unless phase == "all" || phase.blank?
			if phase == "1"
				where(phase: ["Phase 1","Phase 1/Phase 2" ])
			elsif phase == "2"
				where(phase: ["Phase 1/Phase 2","Phase 2","Phase 2/Phase 3"])
			elsif phase == "3"
				where(phase: ["Phase 3","Phase 2/Phase 3","Phase 3/Phase 4"])
			elsif phase == "4"
				where(phase: ["Phase 4","Phase 3/Phase 4"])
			elsif phase == "0"
				where(phase: "Phase 0")
			end	
		end
	}

	scope :fda, -> (fda){
		unless fda == "all" || fda.blank?
			if fda == "reg"
				where(is_fda_regulated: "Yes")
			elsif fda == "nreg"
				where(is_fda_regulated: "No")
			end	
		end
	}

	scope :focus, -> (focus){
		unless focus.blank?
			where('focus ILIKE :focus', focus: "%#{focus}%")
		end
	}

	scope :close_to, -> (coordinates, td=100) {
		if coordinates.blank?
			return
		else
			tmpIdArray = close_to_logic(coordinates, td)
			unless tmpIdArray.blank?
				where(id: tmpIdArray)
			end
		end
	 }

	has_many :sites

	def output_criteria
		inclusion.gsub(/(^|\n\n)(\s)*(-)?(.*)(Exclusion|Inclusion) Criteria(.*)\n\n/i,'<h4>\4\5 Criteria\6</h4>').gsub("\n\n","<br>")
	end

	def output_description
		detailed_description.gsub("\n\n","<br><br>")
	end


private



	def enumerate_age_value
		self.minimum_age = convert_months_to_years(self.originalminage)
		self.maximum_age = convert_months_to_years(self.originalmaxage)
	end

	def convert_months_to_years(age)
		if age.downcase.include? "month"
			(age.to_f/12).floor()
		else
			age
		end
	end

	def self.close_to_logic(coordinates, td)
		# ERIC's refactoring suggestion = self.all.collect { |trial| trial.sites }.flatten.select
		valid_sites = Site.all.near(coordinates,td.to_i)
		valid_trials = []
		valid_sites.each do |site|
			valid_trials << site.trial_id
			
		end
		valid_trials.uniq
		 #[2,3,4,5,6,8]				
	end
end
