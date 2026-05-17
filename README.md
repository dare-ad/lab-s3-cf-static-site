# Private S3 Static Site behind CloudFront with GitHub Actions Deploy



A production-pattern static site hosted on AWS, demonstrating modern CloudFront Origin Access Control (OAC) to keep the S3 origin fully private while serving content publicly over HTTPS, with an automated GitHub Actions deploy pipeline on push to main.



\## Architecture



GitHub repo (main branch) triggers GitHub Actions on push. The runner uses aws s3 sync to upload site/ to a private S3 bucket, then aws cloudfront create-invalidation to clear the CDN cache. CloudFront serves the content publicly over HTTPS, fetching from S3 via OAC SigV4 signing.



\## Key design decisions



\- OAC, not OAI. Origin Access Control is AWS's current recommendation for CloudFront to S3 access. Supports SigV4, KMS-encrypted buckets, all regions. OAI is deprecated.

\- Bucket policy with AWS:SourceArn condition. Locks read access to this specific CloudFront distribution, preventing the confused-deputy attack where another distribution could read the bucket.

\- Public access fully blocked on the bucket. Direct S3 URL returns 403 even with a valid object path.

\- Versioning enabled on the bucket for rollback safety.

\- Least-privilege IAM user for the GitHub Actions deploy. Permissions scoped to S3 ListBucket on this bucket, Get/Put/DeleteObject on bucket objects, and CloudFront CreateInvalidation/GetInvalidation on this distribution. No IAM access, no other AWS services.

\- PriceClass\_100 on the CloudFront distribution keeps cost minimal for a lab.



\## Verification



Direct S3 access returns HTTP 403. CloudFront access returns HTTP 200 with a Via header confirming the edge served the response.



\## Deploy



1\. cd terraform \&\& terraform init \&\& terraform apply

2\. Capture outputs: bucket name, distribution ID, CloudFront domain.

3\. Configure GitHub repo Secrets (AWS\_ACCESS\_KEY\_ID, AWS\_SECRET\_ACCESS\_KEY) and Variables (BUCKET\_NAME, DISTRIBUTION\_ID, AWS\_REGION) using a scoped deploy IAM user.

4\. Push to main. The Actions workflow syncs site/ to S3 and invalidates CloudFront.



\## Teardown



aws s3 rm s3://bucket --recursive, then cd terraform \&\& terraform destroy. CloudFront destroy takes 15-20 minutes.



\## Notes



Built as part of a self-directed DevOps lab series. AI assistance (Claude) was used for scaffolding and review; all infrastructure, IAM scoping, and troubleshooting performed by the author.

