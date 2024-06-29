provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

#deploy s3 bucket 
resource "aws_s3_bucket" "mybucket" {
  bucket        = "eraki-terrafromstatefiles-data-backup"
  
}

#create directroy in bucket
resource "aws_s3_object" "log_directory" {
  bucket = aws_s3_bucket.mybucket.bucket
  key    = "log/"

}
#create directroy in bucket
resource "aws_s3_object" "outgoing_directory" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "outgoing/"

}
#create directroy in bucket
resource "aws_s3_object" "incoming_directory" {
  bucket = aws_s3_bucket.mybucket.bucket
  key    = "incoming/"

}

# deploy lifecycle 

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_config" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    id = "logs-directory"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 365
    }

    status = "Enabled"
  }

  #deploy lifecycle with tag 
  rule {
    id = "outgoing-directory"

    filter {
      tag {
        key   = "Name"
        value = "notDeepArchvie"
      }
      and {
        prefix = "outgoing/"
      }
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }


    status = "Enabled"
  }

  #deploy lifecycle based in object size

  rule {
    id = "incoming-directory"

    filter {
      prefix                   = "incoming/"
      object_size_greater_than = 1000000    # 1MB
      object_size_less_than    = 1000000000 # 1GB
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    status = "Enabled"
  }
}














