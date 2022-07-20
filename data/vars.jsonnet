// variables
local apis = import './data/apis.json';
local subnets = import './data/subnets.json';
local organization_id = '141318256085';
local billing_account_id = '01CF81-4B364B-8D1BDC';
local environments = [{name: 'prod', type: 'prod'}, {name: 'nonprod', type: 'nonprod'}, {name: 'datalabs', type: 'nonprod'}];
local extips = [{name: 'syd-extip1', region: 'australia-southeast1'},{name: 'syd-extip2', region: 'australia-southeast1'}];
local prefix = 'stackql';
local github_org = 'stackql';
local github_repo = 'stackql-gcp-foundations';
local region = 'australia-southeast1';

{
	organization_id: organization_id,
	root_node: organization_id,
	billing_account_id: billing_account_id,
	environments: environments,
	prefix: prefix,
	github_org: github_org,
	github_repo: github_repo,
	region: region,
    network: {
        name: "%s-shared-vpc" % [prefix,],
        subnets: subnets,
        extips: extips,
        nats: [
			{
			  name: "nat-config", 
			  natIpAllocateOption: "MANUAL_ONLY", 
			  natIps: std.map((function(x) "https://compute.googleapis.com/compute/v1/projects/%s-sharedsvc/regions/%s/addresses/%s" % [prefix, x.region, x.name,]), extips),
			  sourceSubnetworkIpRangesToNat: "ALL_SUBNETWORKS_ALL_IP_RANGES"
			},	
	    ],
    },
    root_projects: {
        "terraform_project": {
			displayName: "%s-terraform" % [prefix,],
			projectId: "%s-terraform" % [prefix,],
			environment: "prod",
			apis: apis.terraform,
        },
        "audit_project": {
			displayName: "%s-audit" % [prefix,],
			projectId: "%s-audit" % [prefix,],
			environment: "prod",
			apis: apis.audit,
        },
        "sharedsvc_project": {
			displayName: "%s-sharedsvc" % [prefix,],
			projectId: "%s-sharedsvc" % [prefix,],
			environment: "prod",
			apis: apis.sharedsvc,
        },
    },
    log_sinks: {
        org_level_bucket: {
            location: region,
            bucketId: "%s-org-logs" % [prefix,],
            description: "%s organisation level log store" % [prefix,],
            retentionDays: 365,
            sink: {
                name:  "%s-org-logsink-gcs" % [prefix,],
                description: "%s organisation level aggregated log sink to GCS" % [prefix,],
                // filter: '',
                // exclusions: {},
            },
	    },
        folder_sinks: [
            {
                environment: 'nonprod',
                topicname: "%s-np-log-topic" % [prefix,],
                messageRetentionDuration: '172800s',
                logsinkname: "%s-np-logsink-pubsub" % [prefix,],
                logsinkdesc: "%s nonprod folder level aggregated log sink to PubSub" % [prefix,],
            },
            {
                environment: 'prod',
                topicname: "%s-prod-log-topic" % [prefix,],
                messageRetentionDuration: '345600s',
                logsinkname: "%s-prod-logsink-pubsub" % [prefix,],
                logsinkdesc: "%s prod folder level aggregated log sink to PubSub" % [prefix,],
            },
	    ],
        billing_account_sink: {
            topicname: "%s-billing-log-topic" % [prefix,],
            messageRetentionDuration: '345600s',
            logsinkname: "%s-billing-logsink-pubsub" % [prefix,],
            logsinkdesc: "%s billing account log sink to PubSub" % [prefix,],
        },                        
    },
}