describe "Linear Regression", hybrid: true do
  before :all do
    add_train_data_to_db
  end

  after :all do
    Sample.destroy_all
  end

  it "k-fold cross-validation" do
    loss = 0
    highest_error = -999
    Sample.all.each do |test_sample|
      #HybridClassifier.instance.train *DataSource.instance

      # Train NB and linear models separately
      LinearModel.instance.train *DataSource
        .instance
        .fetch_data_and_labels(Sample.ids.reject{|id| id == test_sample.id or Sample.find(id).label == -100}, :good)

      Lights.instance.train *DataSource
         .instance
         .fetch_data_and_labels(Sample.ids.reject{|x| x == test_sample}, :dark)

      predicted = HybridClassifier.instance.classify test_sample.image.path

      puts "#{predicted} VS #{test_sample.label}"
      predicted = -100 if predicted == "NO POT"
      current_loss = (predicted - test_sample.label).abs
      loss += current_loss
      highest_error = current_loss if current_loss > highest_error
    end
    puts "Average error in cups: #{loss/Sample.count}"
    puts "Highest_error: #{highest_error}"
  end
end
