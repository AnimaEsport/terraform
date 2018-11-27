# Terraform

Create the hosting infrastructure in AWS for Anime eSport.

![Infrastructure Diagram][diagram]

## Planing

Before applying the infrastructure model, you should review the change:

```ssh
docker run -it \
    -v $(pwd):/app/ \
    -w /app/ \
    --env AWS_ACCESS_KEY=<KEY_ID> \
    --env AWS_SECRET_KEY=<SECRET_ID> \
    hashicorp/terraform:light \
    plan
```

## Applying

When you are ready, you can apply the change. Be very careful with the delete,
especially on the RDS database.

```ssh
docker run -it \
    -v $(pwd):/app/ \
    -w /app/ \
    --env AWS_ACCESS_KEY=<KEY_ID> \
    --env AWS_SECRET_KEY=<SECRET_ID> \
    hashicorp/terraform:light \
    apply
```

[diagram]: /diagram.png