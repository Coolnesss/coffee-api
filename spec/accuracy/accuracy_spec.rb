require 'rails_helper'
require 'libsvm'
require 'helpers/file_helper'

include CoffeeStates
include Libsvm


describe "Measuring accuracy using" do
  describe "Linear Regression", lm: true do

    before :all do
      add_train_data_to_db
    end

    after :all do
      Sample.destroy_all
    end

    it "k-fold cross-validation" do
      linear_model = LinearModel.instance
      loss = 0
      highest_error = -999
      Sample.all.reject{|x| x.image_file_name.include? "dark"}.each do |sample|
        linear_model.train *DataSource.instance.fetch_data_and_labels(Sample.ids.reject{|id| id == sample.id or Sample.find(id).label == -100}, :good)
        predicted = linear_model.predict sample.image.path

        puts "#{predicted} VS #{sample.label}"

        current_loss = (predicted - sample.label).abs
        loss += current_loss
        highest_error = current_loss if current_loss > highest_error
      end
      puts "Average error in cups: #{loss/Sample.count}"
      puts "Highest_error: #{highest_error}"
    end
  end

  describe "SVM", svm: true do

    it "k-fold cross-validation", slow: true do

      [:LINEAR, :POLY, :RBF, :SIGMOID].each do |type|

        c = 5
        eps = 0.0001
        svm = Svm.new training_data: IMAGE_NAMES, kernel_type: KernelType.const_get(type), c: c, eps: eps

        [5,10,15].each do |nfold|
          result          = Model.cross_validation(svm.problem, svm.parameter, nfold)
          predicted_name  = CoffeeStates.decode(result)
          correct_labels  = IMAGE_NAMES.map{|x| LABELS[x.split("/").last]}
          correctness     = predicted_name.map.with_index { |p, i| p == correct_labels[i].to_sym }
          correct = correctness.select { |x| x }

          accuracy = correct.size.to_f / correctness.size
          acc_str = "%.2f" % accuracy
          puts "Accuracy[type = #{type}, nfold = #{nfold}] : #{acc_str}, eps: #{eps}, c: #{c}"
        end
      end
    end
  end

  describe "k-NN", knn: true do

    it "20% of random data as test data", fast: true do
      shuffled = IMAGE_NAMES.shuffle
      # 80-20 split
      split_point = (shuffled.size * 0.8).to_i
      training_data = shuffled.take split_point
      test_data = shuffled.drop split_point

      n_misclass = 0
      test_data.each do |test_image_name|
        image = test_image_name

        predicted = Knn.new.classify(image, training_data)
        true_value = LABELS[test_image_name.split("/").last]

        if predicted != true_value
          n_misclass += 1
          # weighted error
          $onefold_error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
        end
        $onefold_error_rate = n_misclass.to_f / test_data.size.to_f
        $onefold_error /= test_data.size.to_f
      end

    end

    it "leave-one-out cross-validation", fast: true do
     n_misclass = 0
     IMAGE_NAMES.each do |test_image_name|
       predicted = Knn.new.classify(test_image_name, IMAGE_NAMES.reject{|x| x == test_image_name})
       true_value = LABELS[test_image_name.split("/").last]

       if predicted != true_value
         n_misclass += 1
         # weighted error
         $LOO_error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
       end
     end
     $LOO_error_rate = n_misclass.to_f / IMAGE_NAMES.size.to_f
     $LOO_error /= IMAGE_NAMES.size.to_f
   end

   after :all do
     puts
     puts "error rate for leave-one-out #{$LOO_error_rate}"
     puts "weighted error for leave-one-out #{$LOO_error}"
     puts "error rate for one-fold #{$onefold_error_rate}"
     puts "weighted error for one-fold #{$onefold_error}"

   end
  end

  describe "Naive Bayes", nb: true do

    $error_rate = 0
    $error = 0

    it "leave-one-out cross-validation" do
       n_misclass = 0

       IMAGE_NAMES.each do |test_image_name|
         NaiveBayes.instance.train IMAGE_NAMES.reject{|x| x == test_image_name}
         predicted = NaiveBayes.instance.classify test_image_name
         true_value = LABELS[test_image_name.split("/").last]
         puts "#{predicted} vs #{true_value}"

         if predicted != true_value
           n_misclass += 1
           # weighted error
           $error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
       end
       $error_rate = n_misclass.to_f / IMAGE_NAMES.size.to_f
       $error /= IMAGE_NAMES.size.to_f
    end

    after :all do
      puts
      puts "Naive bayes error rate #{$error_rate}"
      puts "Naive bayes weighted error #{$error}"
    end
  end
end

  describe "Naive Bayes for dark/light classification", nb_dark: true do

    before :all do
      add_train_data_to_db
    end

    after :all do
      Sample.destroy_all
    end

    $error_rate = 0
    $error = 0

    it "leave-one-out cross-validation" do
       n_misclass = 0
       Sample.all.each do |test_sample|

         data, labels = *DataSource
            .instance
            .fetch_data_and_labels(Sample.ids.reject{|x| x == test_sample}, :dark)

         Lights.instance.train data, labels

         predicted = Lights.instance.classify test_sample.image.path
         true_value = test_sample.label
         puts "#{predicted} vs #{true_value}"

         if predicted != true_value
           n_misclass += 1
         end
       end
       $error_rate = n_misclass.to_f / Sample.count.to_f
    end

    after :all do
      puts
      puts "Naive bayes error rate #{$error_rate}"
    end
  end

end
