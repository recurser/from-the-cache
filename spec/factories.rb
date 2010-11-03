
Factory.define :contact do |contact|
  contact.email   "railskitchensink@recursive-design.com"
  contact.subject "Urgent Problem"
  contact.body    "Please reply ASAP!"
end

Factory.sequence :email do |n|
  "test+#{n}@recursive-design.com"
end