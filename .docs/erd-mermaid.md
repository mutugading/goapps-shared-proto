---
config:
  layout: elk
---
erDiagram
	direction RL
	MST_UOM {
		VARCHAR uom_code PK "KG, MTR, PCS"  
		VARCHAR uom_name  "Kilogram, Meter"  
		VARCHAR uom_category  "WEIGHT, LENGTH, QTY"  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	MST_CURRENCY {
		VARCHAR currency_code PK "IDR, USD, EUR"  
		VARCHAR currency_name  "Indonesian Rupiah"  
		VARCHAR symbol  "Rp, $"  
		BOOLEAN is_base  "true for IDR"  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	MST_EXCHANGE_RATE {
		UUID rate_id PK ""  
		VARCHAR from_currency FK ""  
		VARCHAR to_currency FK ""  
		DECIMAL rate  ""  
		DATE effective_date  ""  
		DATE end_date  ""  
		VARCHAR rate_type  "ACTUAL, FORECAST"  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	MST_DEPARTMENT {
		VARCHAR dept_code PK "MKT, RND, PROD, FIN"  
		VARCHAR dept_name  "Marketing, R&D, Production"  
		BOOLEAN can_create_product  ""  
		BOOLEAN can_fill_param  ""  
		BOOLEAN is_active  ""  
	}

	MST_PROCESS {
		VARCHAR process_code PK "SPG, DTY, ACY"  
		VARCHAR process_name  "Spinning, DTY Process"  
		VARCHAR process_short_name  ""  
		INT default_order  "Default sequence"  
		TEXT description  ""  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	MST_PARAMETER {
		VARCHAR param_code PK "SPEED, DENIER, ELEC_RATE"  
		VARCHAR param_name  "Speed, Denier"  
		VARCHAR param_short_name  ""  
		VARCHAR data_type  "NUMBER, TEXT, BOOLEAN"  
		VARCHAR uom_code FK ""  
		VARCHAR param_category  "INPUT, RATE, CALCULATED"  
		DECIMAL default_value  ""  
		DECIMAL min_value  ""  
		DECIMAL max_value  ""  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	MST_PROCESS_PARAM {
		UUID process_param_id PK ""  
		VARCHAR process_code FK ""  
		VARCHAR param_code FK ""  
		BOOLEAN is_required  ""  
		INT display_order  ""  
		JSONB validation_rules  "min, max, options"  
		BOOLEAN is_active  ""  
	}

	MST_FORMULA {
		UUID formula_id PK ""  
		VARCHAR formula_code UK "COST_ELEC_STD"  
		VARCHAR formula_name  "Electricity Cost"  
		TEXT expression  "ELEC_CONSUMPTION * ELEC_RATE"  
		VARCHAR result_param_code FK "Output param"  
		VARCHAR result_uom_code FK ""  
		JSONB required_params  "List of param_codes needed"  
		TEXT description  ""  
		INT version  ""  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	MST_PROCESS_FORMULA {
		UUID process_formula_id PK ""  
		VARCHAR process_code FK ""  
		UUID formula_id FK ""  
		INT calculation_order  ""  
		BOOLEAN is_active  ""  
	}

	MST_RM_CATEGORY {
		VARCHAR category_code PK "CHIP, OIL, DYES"  
		VARCHAR category_name  "Chips, Oil, Dyes"  
		TEXT description  ""  
		BOOLEAN is_active  ""  
	}

	MST_RM_ITEM {
		VARCHAR item_code PK "CHIP001, OIL001"  
		VARCHAR category_code FK ""  
		VARCHAR item_name  "PET Chips Grade A"  
		VARCHAR uom_code FK ""  
		TEXT specification  ""  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	PRD_TEMPLATE {
		UUID template_id PK ""  
		VARCHAR template_code UK "TPL-SPG-001"  
		VARCHAR template_name  "Spinning Standard"  
		TEXT description  ""  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	PRD_TEMPLATE_ROUTING {
		UUID template_routing_id PK ""  
		UUID template_id FK ""  
		VARCHAR process_code FK ""  
		VARCHAR path_code  "01, 01.01, 02"  
		INT level  ""  
		VARCHAR parent_path  ""  
		DECIMAL default_split_ratio  ""  
	}

	PRD_TEMPLATE_PARAM {
		UUID template_param_id PK ""  
		UUID template_routing_id FK ""  
		VARCHAR param_code FK ""  
		DECIMAL default_value  ""  
		BOOLEAN is_overridable  ""  
	}

	PRD_TEMPLATE_FORMULA {
		UUID template_formula_id PK ""  
		UUID template_routing_id FK ""  
		UUID formula_id FK ""  
		INT calculation_order  ""  
	}

	PRD_PRODUCT {
		UUID product_id PK ""  
		VARCHAR product_code UK "PRD-001"  
		VARCHAR product_name  "Polyester FDY 75D/36F"  
		VARCHAR product_short_name  ""  
		VARCHAR shade_code  ""  
		UUID template_id FK "Optional base template"  
		UUID duplicated_from FK "If duplicated"  
		VARCHAR duplication_note  ""  
		VARCHAR status  "DRAFT, PARAM_PENDING, ROUTING_PENDING, ACTIVE, INACTIVE"  
		VARCHAR created_by_dept FK "MKT, RND"  
		VARCHAR purpose  "COMMERCIAL, TESTING, TRIAL"  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	PRD_PRODUCT_ROUTING {
		UUID routing_id PK ""  
		UUID product_id FK ""  
		VARCHAR process_code FK ""  
		VARCHAR path_code  "01, 01.01, 01.02, 02"  
		INT level  "Depth level"  
		VARCHAR parent_path  "Parent path_code"  
		DECIMAL split_ratio  "0.6 = 60%"  
		VARCHAR merge_to_path  "Path to merge into"  
		INT sort_order  "For UI display"  
		BOOLEAN is_active  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	PRD_PRODUCT_PROCESS {
		UUID product_process_id PK ""  
		UUID product_id FK ""  
		UUID routing_id FK ""  
		VARCHAR process_code FK ""  
		JSONB param_inputs  "Input values with metadata"  
		JSONB param_calculated  "Calculated values"  
		JSONB formula_overrides  "Custom formulas"  
		VARCHAR param_status  "COMPLETE, PARTIAL, PENDING_REQUEST"  
		BOOLEAN is_active  ""  
		TIMESTAMP updated_at  ""  
		VARCHAR updated_by  ""  
	}

	PRD_PRODUCT_RM {
		UUID product_rm_id PK ""  
		UUID product_id FK ""  
		UUID routing_id FK ""  
		VARCHAR item_code FK ""  
		DECIMAL quantity  ""  
		VARCHAR uom_code FK ""  
		VARCHAR source_type  "EXTERNAL, PREV_PROCESS"  
		UUID source_routing_id FK "If from previous"  
		BOOLEAN is_active  ""  
	}

	TRX_PARAM_REQUEST {
		UUID request_id PK ""  
		VARCHAR request_code UK "REQ-2024-001"  
		UUID product_id FK ""  
		UUID routing_id FK ""  
		VARCHAR requested_by_dept FK ""  
		VARCHAR requested_to_dept FK ""  
		JSONB requested_params  "List of param_codes"  
		VARCHAR status  "DRAFT, SUBMITTED, IN_PROGRESS, COMPLETED, REJECTED"  
		VARCHAR priority  "LOW, MEDIUM, HIGH, URGENT"  
		TEXT notes  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP submitted_at  ""  
		TIMESTAMP completed_at  ""  
		VARCHAR completed_by  ""  
	}

	TRX_PARAM_REQUEST_DETAIL {
		UUID detail_id PK ""  
		UUID request_id FK ""  
		VARCHAR param_code FK ""  
		VARCHAR status  "PENDING, FILLED, REJECTED"  
		DECIMAL filled_value  ""  
		TEXT filled_notes  ""  
		VARCHAR filled_by  ""  
		TIMESTAMP filled_at  ""  
	}

	CST_PERIOD {
		UUID period_id PK ""  
		VARCHAR period_code UK "2024-01"  
		DATE period_start  ""  
		DATE period_end  ""  
		VARCHAR period_type  "ACTUAL, FORECAST"  
		VARCHAR status  "OPEN, CLOSED, LOCKED"  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
		TIMESTAMP closed_at  ""  
		VARCHAR closed_by  ""  
	}

	CST_RM_PRICE {
		UUID rm_price_id PK ""  
		UUID period_id FK ""  
		VARCHAR item_code FK ""  
		DECIMAL unit_price  ""  
		VARCHAR currency_code FK ""  
		VARCHAR price_type  "ACTUAL, FORECAST"  
		DATE effective_date  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	CST_PARAM_RATE {
		UUID param_rate_id PK ""  
		UUID period_id FK ""  
		VARCHAR param_code FK ""  
		DECIMAL rate_value  ""  
		VARCHAR uom_code FK ""  
		VARCHAR currency_code FK ""  
		VARCHAR rate_type  "ACTUAL, FORECAST"  
		DATE effective_date  ""  
		TIMESTAMP created_at  ""  
		VARCHAR created_by  ""  
	}

	CAL_JOB {
		UUID job_id PK ""  
		VARCHAR job_code UK "JOB-2024-001"  
		UUID period_id FK ""  
		VARCHAR calculation_type  "ACTUAL, FORECAST"  
		VARCHAR scope  "ALL, SELECTED"  
		JSONB product_filter  ""  
		VARCHAR status  "QUEUED, PROCESSING, COMPLETED, FAILED"  
		INT total_products  ""  
		INT processed_count  ""  
		INT success_count  ""  
		INT failed_count  ""  
		TIMESTAMP queued_at  ""  
		TIMESTAMP started_at  ""  
		TIMESTAMP completed_at  ""  
		VARCHAR created_by  ""  
		TEXT error_message  ""  
	}

	CAL_JOB_DETAIL {
		UUID job_detail_id PK ""  
		UUID job_id FK ""  
		UUID product_id FK ""  
		VARCHAR status  "PENDING, PROCESSING, SUCCESS, FAILED"  
		TIMESTAMP started_at  ""  
		TIMESTAMP completed_at  ""  
		TEXT error_message  ""  
		JSONB error_details  ""  
	}

	CAL_PRODUCT_COST {
		UUID cost_id PK ""  
		UUID period_id FK ""  
		UUID product_id FK ""  
		UUID job_id FK ""  
		VARCHAR calculation_type  "ACTUAL, FORECAST"  
		DECIMAL total_rm_cost  ""  
		DECIMAL total_process_cost  ""  
		DECIMAL total_cost  ""  
		DECIMAL cost_per_unit  ""  
		VARCHAR uom_code FK ""  
		VARCHAR currency_code FK ""  
		JSONB cost_summary  ""  
		VARCHAR status  "CALCULATED, VERIFIED"  
		INT version  ""  
		TIMESTAMP calculated_at  ""  
		VARCHAR calculated_by  ""  
	}

	CAL_PROCESS_COST {
		UUID process_cost_id PK ""  
		UUID cost_id FK ""  
		UUID routing_id FK ""  
		VARCHAR process_code FK ""  
		VARCHAR path_code  ""  
		DECIMAL rm_cost  ""  
		DECIMAL conversion_cost  ""  
		DECIMAL cumulative_cost  ""  
		DECIMAL split_adjusted_cost  ""  
		JSONB calculation_log  "All params & formulas used"  
		TIMESTAMP calculated_at  ""  
	}

	CAL_RM_COST {
		UUID rm_cost_id PK ""  
		UUID process_cost_id FK ""  
		VARCHAR item_code FK ""  
		DECIMAL quantity  ""  
		DECIMAL unit_price  ""  
		DECIMAL total_cost  ""  
		VARCHAR source_type  ""  
		UUID source_process_cost_id FK ""  
	}

	AUD_COST_HISTORY {
		UUID history_id PK ""  
		UUID cost_id FK ""  
		INT version  ""  
		JSONB old_values  ""  
		JSONB new_values  ""  
		VARCHAR change_type  "CREATE, RECALCULATE"  
		VARCHAR changed_by  ""  
		TIMESTAMP changed_at  ""  
		TEXT change_reason  ""  
	}

	AUD_PRODUCT_HISTORY {
		UUID history_id PK ""  
		UUID product_id FK ""  
		VARCHAR action  "CREATE, UPDATE, DUPLICATE, STATUS_CHANGE"  
		JSONB old_values  ""  
		JSONB new_values  ""  
		VARCHAR changed_by  ""  
		TIMESTAMP changed_at  ""  
	}

	MST_PARAMETER}o--||MST_UOM:"measured in"
	MST_EXCHANGE_RATE}o--||MST_CURRENCY:"from"
	MST_EXCHANGE_RATE}o--||MST_CURRENCY:"to"
	MST_PROCESS||--o{MST_PROCESS_PARAM:"has"
	MST_PROCESS_PARAM}o--||MST_PARAMETER:"uses"
	MST_PROCESS||--o{MST_PROCESS_FORMULA:"has"
	MST_PROCESS_FORMULA}o--||MST_FORMULA:"uses"
	MST_FORMULA}o--||MST_PARAMETER:"outputs"
	MST_RM_CATEGORY||--o{MST_RM_ITEM:"contains"
	MST_RM_ITEM}o--||MST_UOM:"measured in"
	PRD_TEMPLATE||--o{PRD_TEMPLATE_ROUTING:"has"
	PRD_TEMPLATE_ROUTING}o--||MST_PROCESS:"uses"
	PRD_TEMPLATE_ROUTING||--o{PRD_TEMPLATE_PARAM:"has"
	PRD_TEMPLATE_PARAM}o--||MST_PARAMETER:"uses"
	PRD_TEMPLATE_ROUTING||--o{PRD_TEMPLATE_FORMULA:"has"
	PRD_TEMPLATE_FORMULA}o--||MST_FORMULA:"uses"
	PRD_PRODUCT}o--o|PRD_TEMPLATE:"based on"
	PRD_PRODUCT}o--o|PRD_PRODUCT:"duplicated from"
	PRD_PRODUCT}o--||MST_DEPARTMENT:"created by"
	PRD_PRODUCT||--o{PRD_PRODUCT_ROUTING:"has"
	PRD_PRODUCT_ROUTING}o--||MST_PROCESS:"uses"
	PRD_PRODUCT||--o{PRD_PRODUCT_PROCESS:"has"
	PRD_PRODUCT_PROCESS}o--||PRD_PRODUCT_ROUTING:"at"
	PRD_PRODUCT||--o{PRD_PRODUCT_RM:"requires"
	PRD_PRODUCT_RM}o--||MST_RM_ITEM:"uses"
	PRD_PRODUCT_RM}o--||PRD_PRODUCT_ROUTING:"at step"
	TRX_PARAM_REQUEST}o--||PRD_PRODUCT:"for"
	TRX_PARAM_REQUEST}o--||PRD_PRODUCT_ROUTING:"at"
	TRX_PARAM_REQUEST}o--||MST_DEPARTMENT:"from"
	TRX_PARAM_REQUEST}o--||MST_DEPARTMENT:"to"
	TRX_PARAM_REQUEST||--o{TRX_PARAM_REQUEST_DETAIL:"contains"
	TRX_PARAM_REQUEST_DETAIL}o--||MST_PARAMETER:"for"
	CST_PERIOD||--o{CST_RM_PRICE:"has"
	CST_RM_PRICE}o--||MST_RM_ITEM:"for"
	CST_RM_PRICE}o--||MST_CURRENCY:"in"
	CST_PERIOD||--o{CST_PARAM_RATE:"has"
	CST_PARAM_RATE}o--||MST_PARAMETER:"for"
	CST_PARAM_RATE}o--||MST_CURRENCY:"in"
	CAL_JOB}o--||CST_PERIOD:"for"
	CAL_JOB||--o{CAL_JOB_DETAIL:"contains"
	CAL_JOB_DETAIL}o--||PRD_PRODUCT:"processes"
	CAL_PRODUCT_COST}o--||CST_PERIOD:"for"
	CAL_PRODUCT_COST}o--||PRD_PRODUCT:"of"
	CAL_PRODUCT_COST}o--||CAL_JOB:"by"
	CAL_PRODUCT_COST}o--||MST_CURRENCY:"in"
	CAL_PRODUCT_COST||--o{CAL_PROCESS_COST:"has"
	CAL_PROCESS_COST}o--||PRD_PRODUCT_ROUTING:"at"
	CAL_PROCESS_COST||--o{CAL_RM_COST:"has"
	CAL_RM_COST}o--||MST_RM_ITEM:"uses"
	CAL_PRODUCT_COST||--o{AUD_COST_HISTORY:"tracked"
	PRD_PRODUCT||--o{AUD_PRODUCT_HISTORY:"tracked"