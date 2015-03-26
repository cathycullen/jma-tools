coach = Coach.create(name: "Jody Michael", email: "jody@jodymichael.com", phone: "312-307-3031")
coach = Coach.create(name: "Maura Koutoujian", email: "maura@jodymichael.com", phone: "312-218-0016")
coach = Coach.create(name: "Nancy Scheel", email: "nancy@jodymichael.com", phone: "786-553-4644")



payment = Payment.create(name: "John Doe", amount: 300, coach_id: 1, payment_date: Date.today, status: "Paid", category_id: 1, transaction_type: "Credit Card")



category = Category.create(name: "Career Coaching")
category = Category.create(name: "Executive Coaching")
category = Category.create(name: "Executive Coaching Individual")
category = Category.create(name: "Life Coaching")
category = Category.create(name: "Trader Coaching")
category = Category.create(name: "Career Strategy")
category = Category.create(name: "Interview Coaching")
category = Category.create(name: "Psychotherapy")
category = Category.create(name: "Accountability Mirror")
category = Category.create(name: "ELI Workshop")
category = Category.create(name: "ELI")
category = Category.create(name: "Wellness Coaching")
category = Category.create(name: "Personal Branding")
category = Category.create(name: "Resume Rewrite")
category = Category.create(name: "Leadership Speaking Engagement")

# 1 Career Coaching
# 2 Executive Coaching
# 3 Executive Coaching Individual
# 4 Life Coaching
# 5 Trader Coaching
# 6 Career Strategy
# 7 Interview Coaching
# 8 Psychotherapy
# 9 Accountability Mirror
# 10 ELI Workshop
# 11 ELI
# 12 Wellness Coaching  nothing for this yet
# 13 Personal Branding
# 14 Resume Rewrite  is listed as 15 because it was deleted then re added
# 15 Leadership Speaking Engagement is listed as 16




workshop = Workshop.create(name: "Jan 2015 Workshop", date: Date.today)

guest = Guest.create(name: "Makena Michael", email: "cathy@softwareoptions.com", amount: 995.0, paid: true, workshop_id: 1)
