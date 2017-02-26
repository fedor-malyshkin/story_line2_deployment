node default  {
	include storyline_infra::elasticsearch
}
node "elasticsearch"  {
	include storyline_infra::elasticsearch
}
