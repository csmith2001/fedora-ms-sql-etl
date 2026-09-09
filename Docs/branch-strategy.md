
## Create feature from develop

```Shell
git checkout -b feature/branch origin develop
```

## Make some changes...

```Shell
git add .
git commit -m "Made xyz changes..."
git push -u origin feature/branch
```

## Merge feature into develop

```Shell
git checkout develop
git pull origin develop
git merge feature/branch
git push origin develop
```

## Create MR

[Link to GitLab](https://gitlab.com/csmith2001/fedora-ms-sql-etl/-/compare)

## Merge main into develop

```Shell
git checkout develop
git merge main
git push origin develop
```
