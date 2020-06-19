function(classif, features, train_label, k, loss_func){
  loss <- c()
  #eval(parse)
  dat <- cbind(train_label,  features)
  dat_temp <- dat %>% group_by(x_cat, y_cat) %>% summarise(pos = 0)
  dat_temp <- as.data.frame(dat_temp[,1:2])
  names <- colnames(features)
  k_folds <- createFolds(1:nrow(dat_temp), k)
  
  for (i in 1:k){
    cat_test <- dat_temp[k_folds[[i]],]
    cat_train <- dat_temp[-k_folds[[i]],]
    test <- inner_join(dat, cat_test)
    train <- inner_join(dat, cat_train)
    
    feat_i <- train[,2:(ncol(train)-2)]
    train_i <- train[,1]
    
    if (classif == "logistic"){
      model <- train(feat_i, as.factor(train_i), method = "glm", family = "binomial")
      class_predict <- as.data.frame(predict.train(model, newdata = test[,2:(ncol(test)-2)]))
      class_true <- as.data.frame(test$train_label)
    }
    else if (classif == "adaboost"){
      model <- adaboost(y = train_i, X = as.matrix(feat_i), tree_depth = 1, n_rounds = 10) 
      class_predict <- as.data.frame(predict.adaboost(model, X = as.matrix(test[,2:(ncol(test)-2)]), type = "response"))
      class_true <- as.data.frame(test$train_label)
    }
    else{
      model <- train(feat_i, as.factor(train_i), method = classif) 
      class_predict <- as.data.frame(predict.train(model, newdata = test[,2:(ncol(test)-2)]))
      class_true <- as.data.frame(test$train_label)
    }
    
    
    ##loss
    if(loss_func == "accuracy"){
      loss <- c(loss, mean(class_predict == class_true))
    }
    #else if(loss_func == "log"){
    
    #}
    
  }
  
  
  CV_loss <- mean(loss)
  
  return(list("fold_loss" = loss, "average_loss" = CV_loss))
  
  
}
